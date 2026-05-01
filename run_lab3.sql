DROP TABLE IF EXISTS my_buildings;
DROP TABLE IF EXISTS links;
DROP TABLE IF EXISTS overture_raw;
DROP TABLE IF EXISTS overture_buildings;

INSTALL spatial;
LOAD spatial;

-- загрузка  данных
CREATE TABLE my_buildings AS
SELECT * FROM ST_Read('data/input.geojson');

-- локальный parquet по bbox  зданий
CREATE TABLE overture_raw AS
WITH my_bbox AS (
    SELECT ST_Extent_Agg(geom) geom
    FROM my_buildings
),
bbox AS (
    SELECT ST_Xmin(geom) AS xmin,
           ST_Ymin(geom) AS ymin,
           ST_Xmax(geom) AS xmax,
           ST_Ymax(geom) AS ymax
    FROM my_bbox
)
SELECT * EXCLUDE geometry, geometry
FROM read_parquet('part-00444-4ebd20bb-df8b-51bf-bf04-9eca0f9b119c-c000.zstd.parquet') data
JOIN bbox
    ON ST_Xmin(geometry) BETWEEN bbox.xmin AND bbox.xmax
    AND ST_Ymin(geometry) BETWEEN bbox.ymin AND bbox.ymax
WHERE try(ST_IsValid(geometry)) = true;

SELECT COUNT(*) AS overture_raw_count FROM overture_raw;

-- экспорт  в GeoJSON с source_type
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
                WHEN osm.user = 'Andrei Paniushkin' THEN 'my'
                WHEN list_contains(
                    list_transform(temp.sources, lambda s: s.dataset),
                    'OpenStreetMap'
                ) THEN 'osm'
                ELSE 'ml'
            END AS source_type
        FROM overture_raw temp
        LEFT JOIN my_buildings osm
            ON try(ST_Intersects(osm.geom, ST_SetCRS(temp.geometry, 'EPSG:4326'))) = true
        ORDER BY
            temp.id,
            (osm.user = 'Andrei Paniushkin') DESC NULLS LAST
    )
)
TO 'client/public/overture.json'
WITH (FORMAT CSV, HEADER false, QUOTE '');

SELECT 'Done!';