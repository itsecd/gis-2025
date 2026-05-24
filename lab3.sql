LOAD spatial;
LOAD httpfs;

SET s3_region = 'us-west-2';
SET geometry_always_xy = true;
SET http_timeout = 300;

DROP TABLE IF EXISTS my_buildings;
CREATE TABLE my_buildings AS
SELECT 
    id,
    ST_SetCRS(geom, 'EPSG:4326') AS geometry,
    building,
    "building:levels" AS building_levels
FROM ST_Read('map.geojson')
WHERE building IS NOT NULL;

SELECT 'Мои здания:' as status, COUNT(*) as count FROM my_buildings;

DROP TABLE IF EXISTS my_bbox;
CREATE TABLE my_bbox AS
SELECT 
    ST_XMin(ST_Extent_Agg(geometry)) AS xmin,
    ST_YMin(ST_Extent_Agg(geometry)) AS ymin,
    ST_XMax(ST_Extent_Agg(geometry)) AS xmax,
    ST_YMax(ST_Extent_Agg(geometry)) AS ymax
FROM my_buildings;

SET VARIABLE minx = (SELECT xmin FROM my_bbox);
SET VARIABLE miny = (SELECT ymin FROM my_bbox);
SET VARIABLE maxx = (SELECT xmax FROM my_bbox);
SET VARIABLE maxy = (SELECT ymax FROM my_bbox);

SELECT 'BBOX:' || getvariable('minx') || ' ' || getvariable('miny') || ' - ' || 
       getvariable('maxx') || ' ' || getvariable('maxy') as bbox_info;

DROP TABLE IF EXISTS overture_buildings_raw;
CREATE TABLE overture_buildings_raw AS
SELECT *
FROM read_parquet(
    's3://overturemaps-us-west-2/release/2026-05-20.0/theme=buildings/type=building/*',
    hive_partitioning=1
)
WHERE bbox.xmin <= getvariable('maxx')
  AND bbox.xmax >= getvariable('minx')
  AND bbox.ymin <= getvariable('maxy')
  AND bbox.ymax >= getvariable('miny')
LIMIT 2000;

DROP TABLE IF EXISTS overture_buildings;
CREATE TABLE overture_buildings AS
SELECT
    o.id,
    o.geometry,
    o.class,
    o.height,
    o.num_floors,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM my_buildings m 
            WHERE ST_Intersects(ST_SetCRS(m.geometry, 'EPSG:4326'), ST_SetCRS(o.geometry, 'EPSG:4326'))
        ) THEN 'my'
        WHEN list_has_any(
            list_transform(o.sources, lambda x : lower(x.dataset)), 
            ['openstreetmap']
        ) THEN 'osm'
        ELSE 'ml'
    END AS source_type
FROM overture_buildings_raw o;

SELECT 
    source_type,
    COUNT(*) as count
FROM overture_buildings
GROUP BY source_type
ORDER BY count DESC;

COPY (
    SELECT 
        geometry,
        source_type,
        id,
        class,
        height,
        num_floors
    FROM overture_buildings
) TO 'overture.geojson' 
WITH (FORMAT GDAL, DRIVER 'GeoJSON', SRS 'EPSG:4326');

SELECT 'Файл overture.geojson создан!' as final_status;
