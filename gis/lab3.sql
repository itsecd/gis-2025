-- Установка расширений
INSTALL spatial;
INSTALL httpfs;
LOAD spatial;
LOAD httpfs;

DROP TABLE IF EXISTS my_data;
CREATE TABLE my_data AS
SELECT 
    id,
    building,
    highway,
    shop,
    landuse,
    "natural" AS natural_type,
    geom
FROM ST_Read('C:\Users\Nikita\Documents\GitHub\gis-2026\gis\map2.geojson');

SELECT 'Всего объектов' AS type, COUNT(*) FROM my_data
UNION ALL
SELECT 'Здания', COUNT(*) FROM my_data WHERE building IS NOT NULL
UNION ALL
SELECT 'Дороги', COUNT(*) FROM my_data WHERE highway IS NOT NULL
UNION ALL
SELECT 'POI', COUNT(*) FROM my_data WHERE shop IS NOT NULL;

DROP TABLE IF EXISTS my_bbox;
CREATE TABLE my_bbox AS
SELECT 
    MIN(ST_XMin(geom)) AS xmin,
    MIN(ST_YMin(geom)) AS ymin,
    MAX(ST_XMax(geom)) AS xmax,
    MAX(ST_YMax(geom)) AS ymax
FROM my_data;

SELECT * FROM my_bbox;

DROP TABLE IF EXISTS overture_buildings;
CREATE TABLE overture_buildings AS
SELECT 
    geometry,
    sources,
    ST_XMin(geometry) AS xmin,
    ST_YMin(geometry) AS ymin,
    ST_XMax(geometry) AS xmax,
    ST_YMax(geometry) AS ymax
FROM read_parquet('s3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/part-00444-4ebd20bb-df8b-51bf-bf04-9eca0f9b119c-c000.zstd.parquet')
WHERE ST_XMin(geometry) BETWEEN (SELECT xmin FROM my_bbox) AND (SELECT xmax FROM my_bbox)
  AND ST_YMin(geometry) BETWEEN (SELECT ymin FROM my_bbox) AND (SELECT ymax FROM my_bbox);

SELECT COUNT(*) AS overture_count FROM overture_buildings;

DROP TABLE IF EXISTS overture_with_source;
CREATE TABLE overture_with_source AS
WITH exploded AS (
    SELECT 
        ob.geometry,
        unnest(ob.sources) AS source_item
    FROM overture_buildings ob
)
SELECT 
    geometry,
    source_item['dataset'] AS dataset,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM my_data md 
            WHERE md.building IS NOT NULL 
              AND ST_Intersects(md.geom, ST_SetCRS(geometry, 'EPSG:4326'))
        ) THEN 'my'
        WHEN source_item['dataset'] = 'OpenStreetMap' THEN 'osm'
        WHEN source_item['dataset'] LIKE '%Microsoft%' 
          OR source_item['dataset'] LIKE '%Google%' 
          OR source_item['dataset'] LIKE '%ML%' THEN 'ml'
        ELSE 'other'
    END AS source_type
FROM exploded;

SELECT source_type, COUNT(*) FROM overture_with_source GROUP BY source_type;

COPY (
    SELECT 
        json_build_object(
            'type', 'FeatureCollection',
            'name', 'overture_map',
            'crs', json_build_object(
                'type', 'name',
                'properties', json_build_object('name', 'urn:ogc:def:crs:OGC::CRS84')
            ),
            'features', json_group_array(
                json_build_object(
                    'type', 'Feature',
                    'geometry', ST_AsGeoJSON(geometry)::json,
                    'properties', json_build_object('source_type', source_type)
                )
            )
        ) AS geojson
    FROM overture_with_source
) TO 'C:\Users\Nikita\Documents\GitHub\gis-2026\gis\overture_map.geojson' 
WITH (FORMAT JSON, ARRAY false);