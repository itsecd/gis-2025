WITH osm_data_geom_bbox AS (
    SELECT ST_Extent_Agg(geom) AS geom
    FROM osm_data
)
SELECT ST_XMin(geom) AS xmin, ST_YMin(geom) AS ymin, ST_XMax(geom) AS xmax, ST_YMax(geom) AS ymax
FROM osm_data_geom_bbox;
-- 49.8250943	53.4699679	49.8505351	53.4835223