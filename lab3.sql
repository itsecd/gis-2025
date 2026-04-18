LOAD spatial;
LOAD httpfs;

CREATE TABLE osm_data AS
SELECT * FROM ST_Read('geojson.json');

CREATE TABLE links AS
WITH raw_data AS (
    SELECT *
    FROM 'https://stac.overturemaps.org/2026-04-15.0/buildings/building/collection.json'
),
raw_links AS (
    SELECT unnest(links) AS link
    FROM raw_data
),
links AS (
    SELECT row_number() OVER () id, link.href
    FROM raw_links
    WHERE link.type = 'application/geo+json'
),
raw_bboxes AS (
    SELECT unnest(extent.spatial.bbox) bbox
    FROM raw_data
),
bboxes AS (
    SELECT row_number() OVER () id, bbox[1] xmin, bbox[2] ymin, bbox[3] xmax, bbox[4] ymax
    FROM raw_bboxes
)
SELECT href, xmin, ymin, xmax, ymax
FROM links
JOIN bboxes ON links.id = bboxes.id;

CREATE TABLE smth_data AS
WITH osm_data_geom_bbox AS (
    SELECT ST_Extent_Agg(geom) geom
    FROM osm_data
),
osm_data_bbox AS (
    SELECT ST_Xmin(geom) AS xmin,
           ST_Ymin(geom) AS ymin,
           ST_Xmax(geom) AS xmax,
           ST_Ymax(geom) AS ymax
    FROM osm_data_geom_bbox
)
SELECT * EXCLUDE geometry, geometry
FROM read_parquet('s3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/part-00479-7f152406-ef1b-5bb5-9814-22f03c679bb6-c000.zstd.parquet') data
JOIN osm_data_bbox
    ON ST_Xmin(geometry) BETWEEN osm_data_bbox.xmin AND osm_data_bbox.xmax
    AND ST_Ymin(geometry) BETWEEN osm_data_bbox.ymin AND osm_data_bbox.ymax
WHERE try(ST_IsValid(geometry)) = true;

COPY (
    SELECT json_object(
        'type', 'FeatureCollection',
        'features', json_group_array(
            json_object(
                'type', 'Feature',
                'geometry', ST_AsGeoJSON(ST_SetCRS(geometry, 'EPSG:4326'))::JSON,
                'properties', json_object('id', id, 'source_type', source_type)
            )
        )
    )
    FROM (
        SELECT DISTINCT ON (temp.id)
            temp.geometry,
            temp.id,
            CASE
                WHEN osm.geom IS NOT NULL THEN 'my'
                WHEN list_contains(list_transform(temp.sources, s -> s.dataset), 'OpenStreetMap') THEN 'osm'
                ELSE 'ml'
            END AS source_type
        FROM smth_data temp
        LEFT JOIN osm_data osm
            ON try(ST_Intersects(osm.geom, ST_SetCRS(temp.geometry, 'EPSG:4326'))) = true
    )
)
TO 'client/vite-project/public/overture.json'
WITH (FORMAT CSV, HEADER false, QUOTE '');
