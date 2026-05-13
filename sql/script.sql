INSTALL spatial;
INSTALL httpfs;

LOAD spatial;
LOAD httpfs;

SET http_timeout = 600;
SET http_retries = 5;
SET s3_region = 'us-west-2';

SET VARIABLE minx = 50.441336;
SET VARIABLE miny = 53.2274563;
SET VARIABLE maxx = 50.4583173;
SET VARIABLE maxy = 53.2315887;

DROP TABLE IF EXISTS my_data;
CREATE TABLE my_data AS
SELECT
  ST_SetCRS(geom, '') AS geometry,
  * EXCLUDE (geom)
FROM ST_Read('data/map_new.geojson');

DROP TABLE IF EXISTS my_buildings;
CREATE TABLE my_buildings AS
SELECT *
FROM my_data
WHERE building IS NOT NULL;

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
links AS (
  SELECT row_number() OVER () AS id, link.href
  FROM raw_links
  WHERE link.type = 'application/geo+json'
),
raw_bboxes AS (
  SELECT unnest(extent.spatial.bbox) AS bbox
  FROM raw_data
),
bboxes AS (
  SELECT
    row_number() OVER () AS id,
    bbox[1] AS xmin,
    bbox[2] AS ymin,
    bbox[3] AS xmax,
    bbox[4] AS ymax
  FROM raw_bboxes
)
SELECT href, xmin, xmax, ymin, ymax
FROM links
JOIN bboxes ON links.id = bboxes.id;

SELECT DISTINCT links.href AS tile_number
FROM links
JOIN my_buildings
  ON ST_XMin(geometry) BETWEEN links.xmin AND links.xmax
 AND ST_YMin(geometry) BETWEEN links.ymin AND links.ymax;

SET VARIABLE overture_parquet = 's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/part-00444-4ebd20bb-df8b-51bf-bf04-9eca0f9b119c-c000.zstd.parquet';

DROP TABLE IF EXISTS overture_buildings_raw;
CREATE TABLE overture_buildings_raw AS
SELECT *
FROM read_parquet(
  getvariable('overture_parquet'),
  filename = true,
  hive_partitioning = 1
)
WHERE ST_XMin(geometry) BETWEEN CAST(getvariable('minx') AS DOUBLE) AND CAST(getvariable('maxx') AS DOUBLE)
  AND ST_YMin(geometry) BETWEEN CAST(getvariable('miny') AS DOUBLE) AND CAST(getvariable('maxy') AS DOUBLE);

SELECT lower(x.dataset) AS dataset, COUNT(*) AS cnt
FROM overture_buildings_raw, UNNEST(sources) AS t(x)
GROUP BY 1
ORDER BY cnt DESC;

DROP TABLE IF EXISTS overture_buildings;
CREATE TABLE overture_buildings AS
SELECT
  o.*,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM my_buildings m
      WHERE ST_Intersects(o.geometry, m.geometry)
    ) THEN 'my'
    WHEN list_has_any(
      list_transform(o.sources, lambda x : lower(x.dataset)),
      ['openstreetmap']
    ) THEN 'osm'
    ELSE 'ml'
  END AS source_type
FROM overture_buildings_raw o;

SELECT source_type, COUNT(*)
FROM overture_buildings
GROUP BY source_type
ORDER BY COUNT(*) DESC;

SET geometry_always_xy = true;

COPY (
  SELECT
    geometry,
    source_type,
    id,
    class,
    subtype,
    level,
    height,
    num_floors
  FROM overture_buildings
)
TO 'client/vite-project/public/overture.geojson'
WITH (
  FORMAT GDAL,
  DRIVER 'GeoJSON',
  LAYER_CREATION_OPTIONS 'WRITE_BBOX=YES',
  SRS 'EPSG:4326'
);
