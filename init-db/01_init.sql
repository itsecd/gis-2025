CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE buildings (
  id SERIAL,
  osm_id TEXT,
  addr_city TEXT,
  addr_housenumber TEXT,
  addr_street TEXT,
  building TEXT,
  building_levels TEXT,
  geom GEOMETRY(MULTIPOLYGON, 4326)
);

INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838431', '�������� ��������� ���������', '4', '1-� �����', 'yes', '2', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2195639,53.5971495],[49.2195515,53.597104],[49.2196848,53.5970911],[49.2196973,53.5971366],[49.2195639,53.5971495]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838432', '�������� ��������� ���������', '92', '2-� �����', 'yes', '2', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2193787,53.5969812],[49.2193594,53.5969126],[49.2195306,53.5968956],[49.2195499,53.5969643],[49.2193787,53.5969812]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838433', '�������� ��������� ���������', '5', '1-� �����', 'yes', '2', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.219772,53.5972799],[49.2197678,53.5972272],[49.2198579,53.5972246],[49.2198622,53.5972774],[49.219772,53.5972799]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838434', '�������� ��������� ���������', '1102', '1-� �����', 'yes', '2', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2200518,53.5972324],[49.2200423,53.5971925],[49.2201456,53.5971838],[49.2201551,53.5972238],[49.2200518,53.5972324]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838435', '�������� ��������� ���������', '2', '1-� �����', 'yes', '', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2192231,53.5973566],[49.2191918,53.5972137],[49.2188075,53.5972434],[49.2187935,53.5971797],[49.2193813,53.5971342],[49.2194266,53.5973408],[49.2192231,53.5973566]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838437', '�������� ��������� ���������', '1121', '2-� �����', 'yes', '2', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2185759,53.5970312],[49.218567,53.5969647],[49.2186925,53.5969602],[49.2186955,53.5970277],[49.2185759,53.5970312]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838438', '�������� ��������� ���������', '1147', '2-� �����', 'yes', '2', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.218835,53.5968602],[49.2188254,53.5967943],[49.2189466,53.5967881],[49.2189562,53.596854],[49.218835,53.5968602]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838439', '�������� ��������� ���������', '91', '2-� �����', 'yes', '2', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2190235,53.5969884],[49.2190085,53.5969239],[49.2191529,53.596912],[49.219168,53.5969765],[49.2190235,53.5969884]]]}')), 4326));
INSERT INTO buildings (osm_id, addr_city, addr_housenumber, addr_street, building, building_levels, geom) VALUES ('way/1499838440', '�������� ��������� ���������', '91', '2-� �����', 'yes', '', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[49.2196467,53.5969391],[49.2196331,53.5968836],[49.2198055,53.5968687],[49.2198192,53.5969242],[49.2196467,53.5969391]]]}')), 4326));

ALTER TABLE buildings ADD CONSTRAINT pk_buildings PRIMARY KEY (id);
CREATE INDEX idx_buildings_geom ON buildings USING GIST (geom);

CREATE TABLE roads (
  id SERIAL,
  osm_id TEXT,
  highway TEXT,
  geom GEOMETRY(MULTILINESTRING, 4326)
);

INSERT INTO roads (osm_id, highway, geom) VALUES ('way/300336484', 'unclassified', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[49.2322051,53.5962034],[49.2255407,53.5968481],[49.2185126,53.597528],[49.2182615,53.5975113]]}')), 4326));
INSERT INTO roads (osm_id, highway, geom) VALUES ('way/300336485', 'service', ST_SetSRID(ST_Multi(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[49.2179762,53.5969953],[49.2200269,53.5968192],[49.2214742,53.5966802],[49.2253731,53.5963047],[49.229019,53.5959574],[49.2307984,53.5957603],[49.2312571,53.5957462],[49.2321181,53.5956635],[49.2379249,53.595106],[49.244959,53.5944306]]}')), 4326));

ALTER TABLE roads ADD CONSTRAINT pk_roads PRIMARY KEY (id);
CREATE INDEX idx_roads_geom ON roads USING GIST (geom);

CREATE TABLE poi (
  id SERIAL,
  name TEXT,
  amenity TEXT,
  is_synthetic BOOLEAN DEFAULT FALSE,
  geom GEOMETRY(POINT, 4326)
);

INSERT INTO poi (name, amenity, is_synthetic, geom) VALUES ('Магазин', 'shop', TRUE, ST_SetSRID(ST_Point(49.2194, 53.5971), 4326));
INSERT INTO poi (name, amenity, is_synthetic, geom) VALUES ('Кафе', 'cafe', TRUE, ST_SetSRID(ST_Point(49.2201, 53.597), 4326));
INSERT INTO poi (name, amenity, is_synthetic, geom) VALUES ('Аптека', 'pharmacy', TRUE, ST_SetSRID(ST_Point(49.219, 53.5966), 4326));

ALTER TABLE poi ADD CONSTRAINT pk_poi PRIMARY KEY (id);
CREATE INDEX idx_poi_geom ON poi USING GIST (geom);
