-- Лабораторная работа №3
-- Совместный анализ локальных данных OSM/GeoJSON и Overture Maps Buildings в DuckDB.
--
-- Входной файл: data/input.geojson
-- Выходной файл: client/public/overture.geojson
--
-- BBOX участка с небольшим запасом вокруг зданий из ЛР1:
-- min_lon = 49.21050, min_lat = 53.59750
-- max_lon = 49.21350, max_lat = 53.60100

INSTALL spatial;
LOAD spatial;
INSTALL httpfs;
LOAD httpfs;

SET s3_region = 'us-west-2';

-- 1. Создание локальной таблицы с пользовательскими зданиями из GeoJSON.
CREATE OR REPLACE TABLE user_buildings AS
SELECT
    row_number() OVER () AS local_id,
    geom,
    id AS osm_id,
    building,
    "building:levels" AS building_levels,
    "addr:street" AS addr_street,
    "addr:housenumber" AS addr_housenumber,
    "addr:city" AS addr_city,
    "addr:postcode" AS addr_postcode
FROM ST_Read('data/input.geojson')
WHERE geom IS NOT NULL;

-- Контроль: геометрия должна быть типом GEOMETRY.
SELECT COUNT(*) AS user_buildings_count FROM user_buildings;
SELECT DISTINCT ST_GeometryType(geom) AS geometry_type FROM user_buildings;

-- 2. BBOX области анализа.
CREATE OR REPLACE TABLE analysis_bbox AS
SELECT
    49.21050::DOUBLE AS minx,
    53.59750::DOUBLE AS miny,
    49.21350::DOUBLE AS maxx,
    53.60100::DOUBLE AS maxy;

-- 3. Поиск партиций Overture Maps Buildings, потенциально пересекающих BBOX.
-- Запрос читает только метаданные Parquet-файлов, сами данные на этом шаге не скачиваются.

CREATE OR REPLACE TABLE overture_partitions AS

WITH files AS (
    SELECT DISTINCT file_name AS file
    FROM parquet_metadata(
        's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*.zstd.parquet'
    )
),

stats AS (
    SELECT
        file_name AS file,

        SUM(
            CASE
                WHEN path_in_schema = 'bbox, xmin'
                 AND TRY_CAST(stats_min_value AS DOUBLE) <= (SELECT maxx FROM analysis_bbox)
                 AND TRY_CAST(stats_max_value AS DOUBLE) >= (SELECT minx FROM analysis_bbox)
                THEN 1
                ELSE 0
            END
        ) AS hit_x,

        SUM(
            CASE
                WHEN path_in_schema = 'bbox, ymin'
                 AND TRY_CAST(stats_min_value AS DOUBLE) <= (SELECT maxy FROM analysis_bbox)
                 AND TRY_CAST(stats_max_value AS DOUBLE) >= (SELECT miny FROM analysis_bbox)
                THEN 1
                ELSE 0
            END
        ) AS hit_y

    FROM parquet_metadata(
        's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*.zstd.parquet'
    )

    WHERE path_in_schema IN ('bbox, xmin', 'bbox, ymin')

    GROUP BY file_name
)

SELECT f.file
FROM files f
JOIN stats s
    ON f.file = s.file
WHERE s.hit_x > 0
  AND s.hit_y > 0;

SELECT COUNT(*) AS selected_overture_partitions FROM overture_partitions;

-- 4. Загрузка зданий Overture Maps по BBOX.
-- В DuckDB CLI не во всех версиях удобно передать список файлов из таблицы в read_parquet.
-- Поэтому ниже используется wildcard + bbox-фильтр. Практический запуск в scripts/run_analysis.py
-- использует список overture_partitions и читает только найденные партиции.
CREATE OR REPLACE TABLE overture_buildings AS
SELECT
    id,
    geometry AS geom,
    sources,
    height,
    num_floors,
    class,
    names."primary" AS name
FROM read_parquet(
    's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*.zstd.parquet',
    filename=true,
    hive_partitioning=1
)
WHERE bbox.xmin <= (SELECT maxx FROM analysis_bbox)
  AND bbox.xmax >= (SELECT minx FROM analysis_bbox)
  AND bbox.ymin <= (SELECT maxy FROM analysis_bbox)
  AND bbox.ymax >= (SELECT miny FROM analysis_bbox);

SELECT COUNT(*) AS overture_buildings_count FROM overture_buildings;

-- 5. Классификация источника.
-- my  — объект Overture пересекается с пользовательскими зданиями из ЛР1;
-- osm — в sources указан OpenStreetMap;
-- ml  — остальные объекты, как правило ML/автоматическое распознавание.
ALTER TABLE overture_buildings ADD COLUMN IF NOT EXISTS source_type VARCHAR;

CREATE OR REPLACE TEMP TABLE my_intersections AS
SELECT DISTINCT o.id
FROM overture_buildings o
JOIN user_buildings u
  ON ST_Intersects(o.geom, u.geom);

UPDATE overture_buildings
SET source_type = CASE
    WHEN id IN (SELECT id FROM my_intersections) THEN 'my'
    WHEN (
        SELECT bool_or(s.dataset ILIKE '%openstreetmap%' OR s.record_id ILIKE '%openstreetmap%' OR s.dataset ILIKE '%osm%')
        FROM unnest(sources) AS t(s)
    ) THEN 'osm'
    ELSE 'ml'
END;

SELECT source_type, COUNT(*) AS cnt
FROM overture_buildings
GROUP BY source_type
ORDER BY cnt DESC;

-- 6. Экспорт результата в GeoJSON.
COPY (
    SELECT
        id,
        source_type,
        COALESCE(class, '') AS class,
        height,
        num_floors,
        COALESCE(name, '') AS name,
        geom
    FROM overture_buildings
    WHERE geom IS NOT NULL
) TO 'client/public/overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON', SRS 'EPSG:4326');
