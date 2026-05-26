INSTALL spatial;
LOAD spatial;
INSTALL httpfs;
LOAD httpfs;

SET s3_region = 'us-west-2';

CREATE OR REPLACE TABLE my_buildings AS
SELECT
    id AS my_id,
    building,
    "building:levels" AS building_levels,
    height,
    geom
FROM ST_Read('../lab1/buildings.geojson');

CREATE OR REPLACE TABLE my_bbox AS
SELECT
    ST_XMin(ST_Extent_Agg(geom)) AS xmin,
    ST_YMin(ST_Extent_Agg(geom)) AS ymin,
    ST_XMax(ST_Extent_Agg(geom)) AS xmax,
    ST_YMax(ST_Extent_Agg(geom)) AS ymax,
    ST_Union_Agg(geom) AS geom
FROM my_buildings;

SET variable xmin = (SELECT xmin FROM my_bbox);
SET variable ymin = (SELECT ymin FROM my_bbox);
SET variable xmax = (SELECT xmax FROM my_bbox);
SET variable ymax = (SELECT ymax FROM my_bbox);

CREATE OR REPLACE TABLE overture_partitions AS
SELECT DISTINCT filename
FROM read_parquet(
    's3://overturemaps-us-west-2/release/2026-05-20.0/theme=buildings/type=building/*',
    filename = true,
    hive_partitioning = 1
)
WHERE bbox.xmin <= getvariable('xmax')
  AND bbox.xmax >= getvariable('xmin')
  AND bbox.ymin <= getvariable('ymax')
  AND bbox.ymax >= getvariable('ymin');

SET variable overture_files = (SELECT list(filename) FROM overture_partitions);

CREATE OR REPLACE TABLE overture_buildings_raw AS
SELECT
    id,
    subtype,
    class,
    height,
    level,
    names.primary AS name,
    sources,
    geometry AS geom
FROM read_parquet(
    getvariable('overture_files'),
    filename = true,
    hive_partitioning = 1
)
WHERE bbox.xmin <= getvariable('xmax')
  AND bbox.xmax >= getvariable('xmin')
  AND bbox.ymin <= getvariable('ymax')
  AND bbox.ymax >= getvariable('ymin');

CREATE OR REPLACE TABLE overture_buildings AS
SELECT
    o.id,
    o.subtype,
    o.class,
    o.height,
    o.level,
    o.name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM my_buildings m
            WHERE ST_Intersects(o.geom, m.geom)
        ) THEN 'my'
        WHEN EXISTS (
            SELECT 1
            FROM UNNEST(o.sources) AS src(source)
            WHERE lower(source.dataset) LIKE '%openstreetmap%'
               OR lower(source.dataset) LIKE '%osm%'
        ) THEN 'osm'
        ELSE 'ml'
    END AS source_type,
    o.geom
FROM overture_buildings_raw o;

SELECT 'my_buildings' AS table_name, count(*) AS feature_count FROM my_buildings;
SELECT 'overture_partitions' AS table_name, count(*) AS partition_count FROM overture_partitions;
SELECT source_type, count(*) AS feature_count FROM overture_buildings GROUP BY source_type ORDER BY source_type;

COPY (
    SELECT
        id,
        subtype,
        class,
        height,
        level,
        name,
        source_type,
        geom
    FROM overture_buildings
) TO '../client/public/overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');
