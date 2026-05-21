
INSTALL spatial;
LOAD spatial;
INSTALL httpfs;
LOAD httpfs;

CREATE OR REPLACE TABLE my_buildings AS
SELECT 
    osm_id,
    geom,
    ST_XMin(geom) AS xmin,
    ST_YMin(geom) AS ymin,
    ST_XMax(geom) AS xmax,
    ST_YMax(geom) AS ymax
FROM ST_Read('./map.geojson');  

CREATE OR REPLACE TABLE my_bbox AS
SELECT 
    MIN(xmin) - 0.01 AS min_x,
    MIN(ymin) - 0.01 AS min_y,
    MAX(xmax) + 0.01 AS max_x,
    MAX(ymax) + 0.01 AS max_y
FROM my_buildings;

SET VARIABLE stac_url = 'https://stac.overturemaps.org/2026-04-15.0/buildings/building/collection.json';

CREATE OR REPLACE TABLE overture_links AS
WITH raw AS (
    SELECT unnest(links) AS link
    FROM read_json(getvariable('stac_url'))
),
items AS (
    SELECT 
        link.href,
        unnest(extent.spatial.bbox) AS bbox
    FROM raw, read_json(link.href)
),
bboxes AS (
    SELECT 
        href,
        bbox[1] AS xmin,
        bbox[2] AS ymin,
        bbox[3] AS xmax,
        bbox[4] AS ymax
    FROM items
)
SELECT 
    href,
    xmin, ymin, xmax, ymax
FROM bboxes
WHERE xmin <= (SELECT max_x FROM my_bbox)
  AND xmax >= (SELECT min_x FROM my_bbox)
  AND ymin <= (SELECT max_y FROM my_bbox)
  AND ymax >= (SELECT min_y FROM my_bbox);

CREATE OR REPLACE TABLE overture_raw AS
SELECT 
    geometry,
    sources,
    ST_XMin(geometry) AS xmin,
    ST_YMin(geometry) AS ymin,
    ST_XMax(geometry) AS xmax,
    ST_YMax(geometry) AS ymax;

CREATE OR REPLACE TABLE overture_filtered AS
SELECT 
    geometry,
    sources
FROM overture_raw, my_bbox
WHERE xmin <= my_bbox.max_x
  AND xmax >= my_bbox.min_x
  AND ymin <= my_bbox.max_y
  AND ymax >= my_bbox.min_y;

CREATE OR REPLACE TABLE overture_classified AS
SELECT 
    o.geometry,
    o.sources,
    CASE 
        WHEN m.geom IS NOT NULL THEN 'my'
        WHEN list_contains(list_transform(o.sources, s -> s.dataset), 'OpenStreetMap') THEN 'osm'
        ELSE 'ml'
    END AS source_type
FROM overture_filtered o
LEFT JOIN my_buildings m
    ON ST_Intersects(o.geometry, m.geom);

COPY (
    SELECT 
        ST_AsGeoJSON(geometry)::JSON AS geometry,
        source_type
    FROM overture_classified
    WHERE source_type IS NOT NULL
) TO 'overture.geojson' 
WITH (FORMAT GDAL, DRIVER 'GeoJSON');