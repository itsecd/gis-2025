-- =====================================================
-- ЛАБОРАТОРНАЯ РАБОТА №3 - ИСПРАВЛЕННЫЙ СКРИПТ
-- =====================================================

INSTALL spatial;
LOAD spatial;
INSTALL httpfs;
LOAD httpfs;

-- ===================== 1. ЗАГРУЗКА  ДАННЫХ =====================

CREATE OR REPLACE TABLE my_buildings_raw AS
SELECT * FROM ST_Read('./map.geojson');

CREATE OR REPLACE TABLE my_buildings AS
SELECT 
    id AS osm_id,
    geom,
    ST_XMin(geom) AS xmin,
    ST_YMin(geom) AS ymin,
    ST_XMax(geom) AS xmax,
    ST_YMax(geom) AS ymax
FROM my_buildings_raw
WHERE ST_GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON');

-- ===================== 2. BBOX =====================

CREATE OR REPLACE TABLE my_bbox AS
SELECT 
    MIN(xmin) - 0.01 AS min_x,
    MIN(ymin) - 0.01 AS min_y,
    MAX(xmax) + 0.01 AS max_x,
    MAX(ymax) + 0.01 AS max_y
FROM my_buildings;

-- ===================== 3. ПОДКЛЮЧЕНИЕ OVERTURE MAPS =====================

SET VARIABLE stac_url = 'https://stac.overturemaps.org/2026-04-15.0/buildings/building/collection.json';

-- Шаг 1: Получаем ссылки из collection.json
CREATE OR REPLACE TABLE overture_links_raw AS
SELECT unnest(links) AS link
FROM read_json(getvariable('stac_url'));

-- Шаг 2: Загружаем метаданные каждой партиции (разбито на 2 запроса, чтобы избежать ошибки)
CREATE OR REPLACE TABLE overture_items AS
SELECT 
    link.href,
    unnest(extent.spatial.bbox) AS bbox
FROM overture_links_raw l, read_json(l.link.href);

-- Шаг 3: Формируем bbox для каждой партиции
CREATE OR REPLACE TABLE overture_bboxes AS
SELECT 
    href,
    bbox[1] AS xmin,
    bbox[2] AS ymin,
    bbox[3] AS xmax,
    bbox[4] AS ymax
FROM overture_items;

-- Шаг 4: Фильтруем партиции по BBOX
CREATE OR REPLACE TABLE overture_links AS
SELECT 
    href,
    xmin, ymin, xmax, ymax
FROM overture_bboxes
WHERE xmin <= (SELECT max_x FROM my_bbox)
  AND xmax >= (SELECT min_x FROM my_bbox)
  AND ymin <= (SELECT max_y FROM my_bbox)
  AND ymax >= (SELECT min_y FROM my_bbox);

-- ===================== 4. ЗАГРУЗКА ДАННЫХ OVERTURE =====================

-- Загружаем данные из найденных партиций (берем первую)
CREATE OR REPLACE TABLE overture_raw AS
SELECT 
    geometry,
    sources,
    ST_XMin(geometry) AS xmin,
    ST_YMin(geometry) AS ymin,
    ST_XMax(geometry) AS xmax,
    ST_YMax(geometry) AS ymax
FROM read_parquet((SELECT href FROM overture_links LIMIT 1));

-- ===================== 5. ФИЛЬТРАЦИЯ ПО BBOX =====================

CREATE OR REPLACE TABLE overture_filtered AS
SELECT 
    geometry,
    sources
FROM overture_raw, my_bbox
WHERE xmin <= my_bbox.max_x
  AND xmax >= my_bbox.min_x
  AND ymin <= my_bbox.max_y
  AND ymax >= my_bbox.min_y;

-- ===================== 6. КЛАССИФИКАЦИЯ ИСТОЧНИКОВ =====================

CREATE OR REPLACE TABLE overture_classified AS
SELECT 
    o.geometry,
    o.sources,
    CASE 
        WHEN m.geom IS NOT NULL THEN 'my'
        WHEN (SELECT bool_or(s.dataset ILIKE '%OpenStreetMap%') 
              FROM unnest(o.sources) AS t(s)) THEN 'osm'
        ELSE 'ml'
    END AS source_type
FROM overture_filtered o
LEFT JOIN my_buildings m
    ON ST_Intersects(o.geometry, m.geom);

-- ===================== 7. ЭКСПОРТ В GEOJSON =====================

COPY (
    SELECT 
        ST_AsGeoJSON(geometry)::JSON AS geometry,
        source_type
    FROM overture_classified
    WHERE source_type IS NOT NULL
) TO 'overture.geojson' 
WITH (FORMAT GDAL, DRIVER 'GeoJSON');

-- ===================== 8. ПРОВЕРКА РЕЗУЛЬТАТА =====================

SELECT source_type, COUNT(*) 
FROM overture_classified 
GROUP BY source_type;