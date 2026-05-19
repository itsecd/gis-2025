LOAD spatial;
LOAD httpfs;

SET s3_region = 'us-west-2';
SET geometry_always_xy = true;
SET VARIABLE overture_release = (
    SELECT latest
    FROM 'https://stac.overturemaps.org/catalog.json'
);

SET VARIABLE overture_partition_url = (
    'https://overturemaps-us-west-2.s3.us-west-2.amazonaws.com/release/'
    || getvariable('overture_release')
    || '/theme=buildings/type=building/part-00444-4ebd20bb-df8b-51bf-bf04-9eca0f9b119c-c000.zstd.parquet'
);

DROP TABLE IF EXISTS my_buildings;
DROP TABLE IF EXISTS my_bbox;
DROP TABLE IF EXISTS overture_partitions;
DROP TABLE IF EXISTS overture_buildings_raw;
DROP TABLE IF EXISTS overture_buildings;

CREATE TABLE my_buildings AS
SELECT
    id,
    building,
    "building:levels" AS building_levels,
    "addr:city" AS addr_city,
    "addr:housenumber" AS addr_housenumber,
    "addr:street" AS addr_street,
    ST_MakeValid(geom)::GEOMETRY AS geom
FROM ST_Read('data/input.geojson')
WHERE building IS NOT NULL
  AND ST_GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON');

CREATE TABLE my_bbox AS
SELECT
    ST_XMin(ST_Extent_Agg(geom)) AS xmin,
    ST_YMin(ST_Extent_Agg(geom)) AS ymin,
    ST_XMax(ST_Extent_Agg(geom)) AS xmax,
    ST_YMax(ST_Extent_Agg(geom)) AS ymax
FROM my_buildings;

SET VARIABLE bbox_xmin = (SELECT xmin FROM my_bbox);
SET VARIABLE bbox_ymin = (SELECT ymin FROM my_bbox);
SET VARIABLE bbox_xmax = (SELECT xmax FROM my_bbox);
SET VARIABLE bbox_ymax = (SELECT ymax FROM my_bbox);

CREATE TABLE overture_partitions AS
SELECT
    getvariable('overture_release') AS release,
    '00444' AS partition_id,
    getvariable('overture_partition_url') AS parquet_url,
    45.30121612548828 AS xmin,
    52.006771087646484 AS ymin,
    53.59000015258789 AS xmax,
    55.54130935668945 AS ymax;

CREATE TABLE overture_buildings_raw AS
SELECT
    o.id,
    o.sources,
    o.height,
    o.num_floors,
    o.subtype,
    o.class,
    ST_MakeValid(o.geometry)::GEOMETRY AS geometry
FROM read_parquet(
    getvariable('overture_partition_url')
) AS o
WHERE o.bbox.xmin <= getvariable('bbox_xmax')
  AND o.bbox.xmax >= getvariable('bbox_xmin')
  AND o.bbox.ymin <= getvariable('bbox_ymax')
  AND o.bbox.ymax >= getvariable('bbox_ymin');

CREATE TABLE overture_buildings AS
SELECT
    o.id,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM my_buildings AS m
            WHERE ST_Intersects(o.geometry, m.geom)
        ) THEN 'my'
        WHEN len(list_filter(o.sources, lambda s: contains(lower(s.dataset), 'openstreetmap'))) > 0 THEN 'osm'
        ELSE 'ml'
    END AS source_type,
    o.height,
    o.num_floors,
    o.subtype,
    o.class,
    o.sources[1].dataset AS primary_source,
    o.geometry
FROM overture_buildings_raw AS o;

COPY (
    SELECT
        id,
        source_type,
        height,
        num_floors,
        subtype,
        class,
        primary_source,
        geometry
    FROM overture_buildings
) TO 'client/public/data/overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');

SELECT
    source_type,
    count(*) AS building_count
FROM overture_buildings
GROUP BY source_type
ORDER BY source_type;
