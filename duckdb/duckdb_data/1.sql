INSTALL spatial;
INSTALL httpfs;

LOAD spatial;
LOAD httpfs;

DROP TABLE IF EXISTS  osm_data;
CREATE TABLE osm_data AS
SELECT *
FROM ST_Read('C:\Users\Donistr\Downloads\gis\data\input.geojson');