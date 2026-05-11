CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS buildings CASCADE;
DROP TABLE IF EXISTS roads CASCADE;
DROP TABLE IF EXISTS poi CASCADE;

CREATE TABLE buildings (
  id SERIAL PRIMARY KEY,
  osm_id TEXT,
  building TEXT,
  building_levels TEXT,
  addr_city TEXT,
  addr_street TEXT,
  addr_housenumber TEXT,
  name TEXT,
  geom GEOMETRY(MULTIPOLYGON, 4326)
);
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-1', 'house', '1', 'сельское поселение Подстепки', 'улица №3', '106', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.21160551332895,53.59865354105496],[49.211582690527315,53.59857093515653],[49.21170526484052,53.5985590058868],[49.21172808369184,53.59864162139095],[49.21160551332895,53.59865354105496]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-2', 'house', '1', 'сельское поселение Подстепки', 'улица №3', '103', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.21170545796721,53.5988935401593],[49.2116916770609,53.59882811405736],[49.21178743048539,53.5988210165285],[49.211801209774414,53.59888643195858],[49.21170545796721,53.5988935401593]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-3', 'house', '1', 'сельское поселение Подстепки', 'улица №3', '101', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.21173063144054,53.59906425291774],[49.21171706700757,53.59900438811488],[49.21179963620925,53.59899779579181],[49.21181320949383,53.59905766341713],[49.21173063144054,53.59906425291774]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-5', 'house', '2', 'сельское поселение Подстепки', 'улица №3', '99', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.21178811516557,53.59941687243926],[49.21176307534899,53.59932916807974],[49.21188134111863,53.59931728427675],[49.211906359783484,53.59940498692521],[49.21178811516557,53.59941687243926]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-6', 'house', '2', 'сельское поселение Подстепки', 'улица №2', '97', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.21188237058158,53.59978163479482],[49.21185625112075,53.59969030531945],[49.21199891390451,53.599675942941985],[49.21202501183253,53.599767276020664],[49.21188237058158,53.59978163479482]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-7', 'house', '1', 'сельское поселение Подстепки', 'улица №3', '95', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.21191875849879,53.599984325045114],[49.211891227587905,53.59989513272686],[49.21204562798056,53.59987835789433],[49.21207313710891,53.59996754973905],[49.21191875849879,53.599984325045114]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-8', 'house', '2', 'сельское поселение Подстепки', 'улица №3', '96', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.212188500666834,53.59996482783679],[49.212158687662175,53.599832802213164],[49.21232005369785,53.599819961809224],[49.21234990318385,53.599951986081706],[49.212188500666834,53.59996482783679]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-9', 'house', '1', 'сельское поселение Подстепки', 'улица №3', '107', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.211861583238566,53.598642046595586],[49.21184855856564,53.59857715025057],[49.21194593600516,53.59857026593185],[49.21195897201437,53.59863515838854],[49.211861583238566,53.598642046595586]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-10', 'house', '1', 'сельское поселение Подстепки', 'улица №3', '105', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.21191406151391,53.59887726559951],[49.211898641576646,53.598799200183635],[49.21207819865149,53.5987867013613],[49.21209362667311,53.59886477857405],[49.21191406151391,53.59887726559951]]]}'), 4326)));
INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES ('way/-11', 'house', '1', 'сельское поселение Подстепки', 'улица №3', '100', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2120681237539,53.59940760925768],[49.21205132028257,53.599336691184604],[49.212198520435486,53.59932440249324],[49.212215323796094,53.59939533569582],[49.2120681237539,53.59940760925768]]]}'), 4326)));
CREATE INDEX idx_buildings_geom ON buildings USING GIST (geom);

CREATE TABLE roads (
  id SERIAL PRIMARY KEY,
  osm_id TEXT,
  name TEXT,
  highway TEXT,
  geom GEOMETRY(MULTILINESTRING, 4326)
);
CREATE INDEX idx_roads_geom ON roads USING GIST (geom);

CREATE TABLE poi (
  id SERIAL PRIMARY KEY,
  osm_id TEXT,
  name TEXT,
  amenity TEXT,
  geom GEOMETRY(POINT, 4326)
);
CREATE INDEX idx_poi_geom ON poi USING GIST (geom);

-- Imported features: buildings=10, roads=0, poi=0