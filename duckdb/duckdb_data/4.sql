DROP TABLE IF EXISTS overture_with_source;
CREATE TABLE overture_with_source AS
WITH exploded AS (
    SELECT overture.*, unnest(sources) AS source_item
    FROM overture_data overture
),
overture_with_source AS (
    SELECT *,
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM osm_data osm 
                WHERE osm.building IS NOT NULL AND ST_Intersects(osm.geom, ST_SetCRS(geometry, 'EPSG:4326'))
            ) THEN 'my'
            WHEN source_item['dataset'] = 'OpenStreetMap' THEN 'osm'
            WHEN source_item['dataset'] LIKE '%Microsoft%' 
     			OR source_item['dataset'] LIKE '%Google%' 
     			OR source_item['dataset'] LIKE '%ML%'
     			OR source_item['dataset'] LIKE '%machine learning%' THEN 'ml'
            ELSE 'other'
        END AS source_type
    FROM exploded
)
SELECT * FROM overture_with_source;

COPY overture_with_source
TO 'C:\Users\Donistr\Downloads\gis\duckdb\duckdb_data\overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');