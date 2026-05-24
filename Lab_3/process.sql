INSTALL spatial;
INSTALL httpfs;
LOAD spatial;
LOAD httpfs;

DROP TABLE IF EXISTS osm_data;
CREATE TABLE osm_data AS
SELECT *
FROM ST_Read('map.geojson')
WHERE building IS NOT NULL
  AND ST_GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON');

DROP TABLE IF EXISTS links;
CREATE TABLE links AS
WITH raw_data AS (
    SELECT *
    FROM 'https://stac.overturemaps.org/2026-04-15.0/buildings/building/collection.json'
),
raw_links AS (
    SELECT unnest(links) AS link
    FROM raw_data
),
ext_links AS (
    SELECT row_number() OVER () AS id, link.href AS href
    FROM raw_links
    WHERE link.type = 'application/geo+json'
),
raw_bboxes AS (
    SELECT unnest(extent.spatial.bbox) AS bbox
    FROM raw_data
),
bboxes AS (
    SELECT row_number() OVER () AS id,
           bbox[1] AS xmin, bbox[2] AS ymin,
           bbox[3] AS xmax, bbox[4] ymax
    FROM raw_bboxes
)
SELECT ext_links.href, bboxes.xmin, bboxes.ymin, bboxes.xmax, bboxes.ymax
FROM ext_links
JOIN bboxes ON ext_links.id = bboxes.id;

CREATE OR REPLACE TEMP TABLE osm_bbox AS
WITH agg AS (
    SELECT ST_Extent_Agg(geom) AS g FROM osm_data
)
SELECT ST_Xmin(g) - 0.005 AS xmin, ST_Ymin(g) - 0.005 AS ymin,
       ST_Xmax(g) + 0.005 AS xmax, ST_Ymax(g) + 0.005 AS ymax
FROM agg;

CREATE OR REPLACE TEMP TABLE matched_links AS
SELECT DISTINCT
    'https://stac.overturemaps.org/2026-04-15.0/buildings/building/' || links.href AS item_url
FROM links, osm_bbox
WHERE NOT (links.xmax < osm_bbox.xmin
        OR links.xmin > osm_bbox.xmax
        OR links.ymax < osm_bbox.ymin
        OR links.ymin > osm_bbox.ymax);

SET VARIABLE item_urls = (SELECT list(item_url) FROM matched_links);

CREATE OR REPLACE TEMP TABLE s3_files AS
SELECT DISTINCT j.assets.aws.alternate.s3.href AS s3_href
FROM read_json(getvariable('item_urls')) AS j;

SET VARIABLE s3_hrefs = (SELECT list(s3_href) FROM s3_files);

DROP TABLE IF EXISTS overture_buildings;
CREATE TABLE overture_buildings AS
WITH bbox_poly AS (
    SELECT ST_MakeEnvelope(xmin, ymin, xmax, ymax) AS env
    FROM osm_bbox
),
raw AS (
    SELECT data.*
    FROM read_parquet(getvariable('s3_hrefs'), filename = true) AS data, bbox_poly
    WHERE try(ST_IsValid(data.geometry)) = true
      AND ST_Intersects(data.geometry, bbox_poly.env)
)
SELECT DISTINCT ON (raw.id)
    raw.id,
    raw.geometry,
    raw.sources,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM osm_data o
            WHERE try(ST_Intersects(o.geom, ST_SetCRS(raw.geometry, 'EPSG:4326'))) = true
        ) THEN 'my'
        WHEN list_contains(
            list_transform(raw.sources, s -> s.dataset),
            'OpenStreetMap'
        ) THEN 'osm'
        ELSE 'ml'
    END AS source_type
FROM raw;

COPY (
    SELECT json_object(
        'type', 'FeatureCollection',
        'features', json_group_array(
            json_object(
                'type', 'Feature',
                'geometry', ST_AsGeoJSON(ST_SetCRS(geometry, 'EPSG:4326'))::JSON,
                'properties', json_object(
                    'id', id,
                    'source_type', source_type
                )
            )
        )
    )
    FROM overture_buildings
)
TO './overture.geojson'
WITH (FORMAT CSV, HEADER false, QUOTE '');