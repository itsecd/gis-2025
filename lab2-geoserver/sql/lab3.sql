-- =====================================================================
-- Лабораторная работа №3
-- Совместный анализ данных с Overture Maps
-- и построение тематической карты
--
-- INPUT:
--   map.GeoJSON
--
-- OUTPUT:
--   client/public/data/overture.geojson
--
-- IMPORTANT:
--   Run this script from the project root folder:
--   LAB2-GEOSERVER/
-- =====================================================================


-- =====================================================================
-- 1. Load required DuckDB extensions
-- =====================================================================

INSTALL spatial;
INSTALL httpfs;

LOAD spatial;
LOAD httpfs;

-- Overture Maps data is hosted in AWS us-west-2
SET s3_region = 'us-west-2';


-- =====================================================================
-- 2. Get latest Overture Maps release from STAC catalog
-- =====================================================================

SET VARIABLE latest_release = (
    SELECT latest
    FROM 'https://stac.overturemaps.org/catalog.json'
);

SET VARIABLE overture_buildings_path = (
    SELECT
        's3://overturemaps-us-west-2/release/'
        || getvariable('latest_release')
        || '/theme=buildings/type=building/*'
);

SELECT
    getvariable('latest_release') AS overture_release,
    getvariable('overture_buildings_path') AS overture_buildings_path;


-- =====================================================================
-- 3. Load user's GeoJSON from Lab 1
-- =====================================================================

CREATE OR REPLACE TABLE my_buildings AS
SELECT
    row_number() OVER () AS my_id,
    ST_SetCRS(ST_MakeValid(geom), 'OGC:CRS84') AS geom
FROM ST_Read('map.GeoJSON')
WHERE geom IS NOT NULL;

-- Check user's buildings count
SELECT
    COUNT(*) AS my_buildings_count
FROM my_buildings;


-- =====================================================================
-- 4. Calculate bbox of user's buildings
-- =====================================================================

CREATE OR REPLACE TABLE my_bbox AS
SELECT
    ST_Extent_Agg(geom) AS geom
FROM my_buildings;

SET VARIABLE xmin = (SELECT ST_XMin(geom) FROM my_bbox);
SET VARIABLE ymin = (SELECT ST_YMin(geom) FROM my_bbox);
SET VARIABLE xmax = (SELECT ST_XMax(geom) FROM my_bbox);
SET VARIABLE ymax = (SELECT ST_YMax(geom) FROM my_bbox);

SET VARIABLE my_bbox_geom = (
    SELECT geom
    FROM my_bbox
);

-- Debug bbox
SELECT
    getvariable('xmin') AS xmin,
    getvariable('ymin') AS ymin,
    getvariable('xmax') AS xmax,
    getvariable('ymax') AS ymax;


-- =====================================================================
-- 5. Find only Overture Buildings files intersecting user's bbox
-- =====================================================================

CREATE OR REPLACE TABLE overture_partitions AS
SELECT DISTINCT
    filename
FROM read_parquet(
    getvariable('overture_buildings_path'),
    filename = true,
    hive_partitioning = 1
)
WHERE
    bbox.xmin <= getvariable('xmax')
    AND bbox.xmax >= getvariable('xmin')
    AND bbox.ymin <= getvariable('ymax')
    AND bbox.ymax >= getvariable('ymin');

-- Check selected Overture files
SELECT
    COUNT(*) AS selected_overture_files
FROM overture_partitions;

SELECT *
FROM overture_partitions;


-- =====================================================================
-- 6. Read only selected Overture files and filter buildings by bbox
-- =====================================================================

SET VARIABLE overture_files = (
    SELECT list(filename)
    FROM overture_partitions
);

CREATE OR REPLACE TABLE overture_buildings_raw AS
SELECT
    data.id,
    data.names.primary AS name,
    data.subtype,
    data.class,
    data.height,
    data.num_floors,
    data.sources,
    data.bbox,
    ST_SetCRS(ST_MakeValid(data.geometry), 'OGC:CRS84') AS geometry
FROM read_parquet(
    getvariable('overture_files'),
    filename = true,
    hive_partitioning = 1
) AS data
WHERE
    data.geometry IS NOT NULL

    -- Fast bbox filter
    AND data.bbox.xmin <= getvariable('xmax')
    AND data.bbox.xmax >= getvariable('xmin')
    AND data.bbox.ymin <= getvariable('ymax')
    AND data.bbox.ymax >= getvariable('ymin')

    -- More precise spatial filter
    AND try(ST_Intersects(ST_SetCRS(data.geometry, 'OGC:CRS84'), getvariable('my_bbox_geom')))= true;

-- Check raw Overture buildings count
SELECT
    COUNT(*) AS overture_buildings_raw_count
FROM overture_buildings_raw;


-- =====================================================================
-- 7. Add source_type field: my / osm / ml
-- =====================================================================
-- Priority:
--   1. my  - if Overture building intersects user's digitized geometry
--   2. osm - if source contains OpenStreetMap / OSM
--   3. ml  - otherwise, treated as automatic / ML source
-- =====================================================================

CREATE OR REPLACE TABLE overture_buildings AS
SELECT
    o.geometry,
    o.id,
    o.name,
    o.subtype,
    o.class,
    o.height,
    o.num_floors,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM my_buildings m
            WHERE try(ST_Intersects(ST_SetCRS(o.geometry, 'OGC:CRS84'), ST_SetCRS(m.geom, 'OGC:CRS84')))= true
        )
        THEN 'my'

        WHEN lower(COALESCE(CAST(o.sources AS VARCHAR), '')) LIKE '%openstreetmap%'
          OR lower(COALESCE(CAST(o.sources AS VARCHAR), '')) LIKE '%osm%'
        THEN 'osm'

        ELSE 'ml'
    END AS source_type,

    CAST(o.sources AS VARCHAR) AS sources_text

FROM overture_buildings_raw o;


-- =====================================================================
-- 8. Check final statistics
-- =====================================================================

SELECT
    source_type,
    COUNT(*) AS count_buildings
FROM overture_buildings
GROUP BY source_type
ORDER BY source_type;


-- =====================================================================
-- 9. Export final GeoJSON layer for OpenLayers client
-- =====================================================================

COPY (
    SELECT
        id,
        name,
        subtype,
        class,
        height,
        num_floors,
        source_type,
        sources_text,
        geometry
    FROM overture_buildings
)
TO 'client/public/data/overture.geojson'
WITH (
    FORMAT GDAL,
    DRIVER 'GeoJSON',
    LAYER_CREATION_OPTIONS 'WRITE_BBOX=YES',
    SRS 'EPSG:4326'
);


-- =====================================================================
-- 10. Final check
-- =====================================================================

SELECT
    'GeoJSON exported to client/public/data/overture.geojson' AS result,
    COUNT(*) AS exported_features
FROM overture_buildings;