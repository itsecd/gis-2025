INSTALL spatial;
LOAD spatial;

DROP TABLE IF EXISTS user_buildings;

CREATE TABLE user_buildings AS
SELECT *
FROM ST_Read('lab.geojson');
