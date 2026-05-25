INSTALL spatial;
INSTALL httpfs;

LOAD spatial;
LOAD httpfs;

SET s3_region='us-west-2';
SET geometry_always_xy = true;
SET http_timeout = 300;

DROP TABLE IF EXISTS my_objects;
CREATE TABLE my_objects AS
SELECT *
FROM ST_Read('map_v2.geojson');

DROP TABLE IF EXISTS my_buildings;
CREATE TABLE my_buildings AS
SELECT *
FROM my_objects
WHERE building IS NOT NULL;

DROP TABLE IF EXISTS my_bbox;
CREATE TABLE my_bbox AS
SELECT
    ST_XMin(ST_Extent_Agg(geom)) AS xmin,
    ST_YMin(ST_Extent_Agg(geom)) AS ymin,
    ST_XMax(ST_Extent_Agg(geom)) AS xmax,
    ST_YMax(ST_Extent_Agg(geom)) AS ymax
FROM my_buildings;

DROP TABLE IF EXISTS overture_partition_candidates;
CREATE TABLE overture_partition_candidates AS
WITH stac AS (
    SELECT extent.spatial.bbox AS bboxes
    FROM read_json_auto(
        'https://stac.overturemaps.org/2026-05-20.0/buildings/building/collection.json'
    )
),
partitions AS (
    SELECT
        printf('%05d', generate_subscripts(bboxes, 1) - 1) AS partition_id,
        unnest(bboxes) AS bbox
    FROM stac
)
SELECT
    partition_id,
    bbox[1] AS xmin,
    bbox[2] AS ymin,
    bbox[3] AS xmax,
    bbox[4] AS ymax,
    'https://stac.overturemaps.org/2026-05-20.0/buildings/building/'
        || partition_id
        || '/'
        || partition_id
        || '.json' AS item_url
FROM partitions
WHERE
    bbox[1] <= (SELECT xmax FROM my_bbox)
    AND bbox[3] >= (SELECT xmin FROM my_bbox)
    AND bbox[2] <= (SELECT ymax FROM my_bbox)
    AND bbox[4] >= (SELECT ymin FROM my_bbox)
ORDER BY partition_id;

SET VARIABLE overture_item_urls = (
    SELECT list(item_url ORDER BY partition_id)
    FROM overture_partition_candidates
);

DROP TABLE IF EXISTS overture_partitions;
CREATE TABLE overture_partitions AS
SELECT
    c.partition_id,
    c.xmin,
    c.ymin,
    c.xmax,
    c.ymax,
    i.assets.aws.href AS url
FROM overture_partition_candidates c
JOIN read_json_auto(getvariable('overture_item_urls')) i
    ON i.id = c.partition_id
ORDER BY c.partition_id;

SET VARIABLE overture_parquet_urls = (
    SELECT list(url ORDER BY partition_id)
    FROM overture_partitions
);

DROP TABLE IF EXISTS overture_buildings_raw;
CREATE TABLE overture_buildings_raw AS
SELECT *
FROM read_parquet(
    getvariable('overture_parquet_urls'),
    filename=true
)
WHERE
    bbox.xmin <= (SELECT xmax FROM my_bbox)
    AND bbox.xmax >= (SELECT xmin FROM my_bbox)
    AND bbox.ymin <= (SELECT ymax FROM my_bbox)
    AND bbox.ymax >= (SELECT ymin FROM my_bbox);

DROP TABLE IF EXISTS overture_buildings;
CREATE TABLE overture_buildings AS
SELECT
    o.id,
    o.geometry,
    o.height,
    o.num_floors,
    o.subtype,
    o.class,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM my_buildings m
            WHERE ST_Intersects(o.geometry, ST_SetCRS(m.geom, 'OGC:CRS84'))
                AND (m.changeset = '180910863' 
                OR m.changeset = '181608189' 
                OR m.changeset = '182484669' 
                OR m.changeset = '183126912')
        ) THEN 'my'

    WHEN CAST(o.sources AS VARCHAR) ILIKE '%OpenStreetMap%' THEN 'osm'

    WHEN
        CAST(o.sources AS VARCHAR) ILIKE '%Microsoft%'
        OR CAST(o.sources AS VARCHAR) ILIKE '%Google%'
        OR CAST(o.sources AS VARCHAR) ILIKE '%ML%'
    THEN 'ml'

    ELSE 'ml'
    END AS source_type
FROM overture_buildings_raw o;

SELECT 
    source_type,
    COUNT(*) as count
FROM overture_buildings
GROUP BY source_type
ORDER BY count DESC;

COPY overture_buildings
TO 'overture.geojson'
WITH (
    FORMAT GDAL,
    DRIVER 'GeoJSON',
    SRS 'EPSG:4326'
);