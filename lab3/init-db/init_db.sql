INSTALL spatial;
LOAD spatial;

INSTALL httpfs;
LOAD httpfs;

SET s3_region='us-west-2';

CREATE OR REPLACE TABLE my_buildings AS
SELECT *
FROM ST_Read('E:/СОХРАНЯТЬ/УЧЕБА/Geo/gis-2026/map_new.geojson');

CREATE OR REPLACE TABLE my_buildings_only AS
SELECT *
FROM my_buildings
WHERE "user" = 'Beni_nika_007';

CREATE OR REPLACE TABLE bbox AS
SELECT ST_Extent(geom) AS extent
FROM my_buildings_only;

CREATE OR REPLACE TABLE overture_buildings AS
SELECT *
FROM read_parquet(
    's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*',
    hive_partitioning=1
)
WHERE ST_XMin(geom) <= (SELECT ST_XMax(extent) FROM bbox LIMIT 1)
AND ST_XMax(geom) >= (SELECT ST_XMin(extent) FROM bbox LIMIT 1)
AND ST_YMin(geom) <= (SELECT ST_YMax(extent) FROM bbox LIMIT 1)
AND ST_YMax(geom) >= (SELECT ST_YMin(extent) FROM bbox LIMIT 1);

ALTER TABLE overture_buildings 
ADD COLUMN source_type TEXT;

UPDATE overture_buildings ob
SET source_type = 'my'
WHERE EXISTS (
    SELECT 1
    FROM my_buildings_only gd
    WHERE ST_Contains(
        gd.geom,
        ST_Centroid(ob.geometry)
    )
    AND ST_Area(gd.geom) < 0.000001
);

UPDATE overture_buildings
SET source_type = CASE
    WHEN CAST(sources AS VARCHAR) LIKE '%OpenStreetMap%' THEN 'osm'
    ELSE 'ml'
END
WHERE source_type IS NULL;

COPY (
    SELECT 
        geom AS geometry,
        'my' AS source_type,
        uid AS id,
        NULL AS name,
        building AS class,
        NULL AS height,
        NULL AS level,
        NULL AS sources
    FROM my_buildings_only

    UNION ALL

    SELECT 
        geometry,
        source_type,
        id,
        names.primary AS name,
        class,
        height,
        level,
        CAST(sources AS VARCHAR) AS sources
    FROM overture_buildings
    WHERE source_type != 'my'

) TO 'lab3/overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');