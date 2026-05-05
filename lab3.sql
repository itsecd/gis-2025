INSTALL spatial;
LOAD spatial;

DROP TABLE IF EXISTS my_buildings;

-- читаем данные из json 
CREATE TABLE my_buildings AS
SELECT *
FROM ST_Read('map.json');

ALTER TABLE my_buildings
RENAME COLUMN geom TO geometry;

-- Получение bbox

SELECT 
    MIN(ST_XMin(geometry)) AS xmin,
    MIN(ST_YMin(geometry)) AS ymin,
    MAX(ST_XMax(geometry)) AS xmax,
    MAX(ST_YMax(geometry)) AS ymax
FROM my_buildings;

-- Overture Buildings

INSTALL httpfs;
LOAD httpfs;

-- DROP TABLE IF EXISTS overture_buildings;

-- SET allow_asterisks_in_http_paths = true;
-- SET s3_region='us-west-2';
-- SET s3_url_style='path';

-- CREATE TABLE overture_buildings AS
-- SELECT *
-- FROM read_parquet(
--     's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*.parquet',
--     hive_partitioning=1
-- )
-- WHERE bbox.xmin <= 87.1215765
--   AND bbox.xmax >= 83.8037054
--   AND bbox.ymin <= 54.9050437
--   AND bbox.ymax >= 53.2750717;

ALTER TABLE overture_buildings
ADD COLUMN IF NOT EXISTS source_type VARCHAR;

UPDATE overture_buildings o
SET source_type = 'my'
WHERE EXISTS (
    SELECT 1
    FROM my_buildings m
    WHERE m."user" = 'dmstepanov'
      AND ST_Intersects(
            ST_SetCRS(o.geometry, 'EPSG:4326'),
            ST_SetCRS(m.geometry, 'EPSG:4326')
      )
);

UPDATE overture_buildings o
SET source_type = 'osm'
WHERE source_type IS NULL
AND EXISTS (
    SELECT 1
    FROM UNNEST(o.sources) AS t(s)
    WHERE s.dataset = 'OpenStreetMap'
);

UPDATE overture_buildings o
SET source_type = 'ml'
WHERE source_type IS NULL
AND EXISTS (
    SELECT 1
    FROM UNNEST(o.sources) AS t(s)
    WHERE s.dataset ILIKE '%Microsoft%'
       OR s.dataset ILIKE '%Google%'
       OR s.dataset ILIKE '%ML%'
);

-- SELECT source_type FROM overture_buildings
-- WHERE source_type = 'my';

SET geometry_always_xy = true;

COPY (
    SELECT 
        geometry,
        source_type
    FROM overture_buildings
    OFFSET 145000
    LIMIT 25000
) -- ограничил так как в бд 400к+ объектов и клиент это не смог отрисовать
TO 'overture.geojson' 
(FORMAT GDAL, DRIVER 'GeoJSON');
-- файл перенесен в клиента gis-2026\client\geo-lab2-client\public\