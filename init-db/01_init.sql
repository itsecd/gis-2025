-- DDL + seed data

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS buildings (
    ogc_fid  SERIAL PRIMARY KEY,
    osm_id   TEXT,
    name     TEXT,
    building TEXT,
    building_levels INTEGER,
    height   TEXT,
    geom     GEOMETRY(MultiPolygon, 4326)
);

INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1462240772', NULL, 'commercial', 8, NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[50.194649, 53.2205825], [50.1950793, 53.2202499], [50.1952985, 53.2203516], [50.1948683, 53.2206842], [50.194649, 53.2205825]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1462240775', NULL, 'commercial', 2, NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[50.1953581, 53.2209507], [50.1949911, 53.2207814], [50.1952308, 53.2205951], [50.1953901, 53.2206686], [50.1953729, 53.2206841], [50.1952555, 53.2207732], [50.1954633, 53.220869], [50.1953581, 53.2209507]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1462240776', NULL, 'commercial', 2, NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[50.1953729, 53.2206841], [50.1954729, 53.220608], [50.19581, 53.220767], [50.19571, 53.220843], [50.1953729, 53.2206841]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/27503370', NULL, 'commercial', 5, NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[50.2228353, 53.2346093], [50.2230107, 53.2344738], [50.2235445, 53.2347211], [50.2233692, 53.2348567], [50.2229629, 53.2346684], [50.2228353, 53.2346093]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1474204392', 'Дачный дом', 'house', 2, '6.5', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[49.3985038, 53.7314329], [49.3984961, 53.7313838], [49.3985797, 53.7313792], [49.3985875, 53.7314283], [49.3985038, 53.7314329]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1474210131', 'Гараж', 'carport', 1, '3', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[49.3985038, 53.7314329], [49.3984589, 53.7314359], [49.3984498, 53.7313876], [49.3984961, 53.7313838], [49.3985038, 53.7314329]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1474210132', 'Баня', 'yes', 1, NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[49.3984412, 53.7313762], [49.3984325, 53.7313139], [49.3985093, 53.7313122], [49.3985142, 53.7313726], [49.3984412, 53.7313762]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1474210134', 'Летний Курятник', 'yes', 1, '2', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[49.3986218, 53.7311645], [49.3986268, 53.7311896], [49.3985324, 53.7311962], [49.3985274, 53.7311712], [49.3986218, 53.7311645]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1474210135', NULL, 'shed', 1, '2', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[49.3986413, 53.731185], [49.3986369, 53.7311639], [49.3987528, 53.7311556], [49.3987571, 53.7311767], [49.3986413, 53.731185]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1474210136', NULL, 'greenhouse', 1, '2', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[49.3986683, 53.7311985], [49.3987651, 53.7311907], [49.3987702, 53.7312129], [49.3986735, 53.7312207], [49.3986683, 53.7311985]]]}'), 4326)));
INSERT INTO buildings (osm_id, name, building, building_levels, height, geom) VALUES ('way/1474210137', NULL, 'greenhouse', 1, '2', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[49.3984413, 53.7312548], [49.398431, 53.731203], [49.3984754, 53.7311999], [49.3984858, 53.7312517], [49.3984413, 53.7312548]]]}'), 4326)));

CREATE INDEX IF NOT EXISTS idx_buildings_geom ON buildings USING GIST (geom);

CREATE TABLE IF NOT EXISTS roads (
    ogc_fid  SERIAL PRIMARY KEY,
    osm_id   TEXT,
    name     TEXT,
    highway  TEXT,
    geom     GEOMETRY(MultiLineString, 4326)
);

INSERT INTO roads (osm_id, name, highway, geom) VALUES ('way/1462240773', NULL, 'service', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "LineString", "coordinates": [[50.1950296, 53.2201264], [50.1944594, 53.2205719], [50.1946973, 53.2206801], [50.1948891, 53.2207675], [50.1950435, 53.2206451]]}'), 4326)));
INSERT INTO roads (osm_id, name, highway, geom) VALUES ('way/1462240774', NULL, 'service', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "LineString", "coordinates": [[50.1946973, 53.2206801], [50.1943849, 53.2209345]]}'), 4326)));
INSERT INTO roads (osm_id, name, highway, geom) VALUES ('way/589102125', NULL, 'service', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "LineString", "coordinates": [[49.3896198, 53.7322019], [49.3923157, 53.7319745], [49.3957722, 53.7317075], [49.3987101, 53.7314731], [49.4004548, 53.7313407]]}'), 4326)));

CREATE INDEX IF NOT EXISTS idx_roads_geom ON roads USING GIST (geom);

CREATE TABLE IF NOT EXISTS poi (
    ogc_fid  SERIAL PRIMARY KEY,
    osm_id   TEXT,
    name     TEXT,
    amenity  TEXT,
    shop     TEXT,
    office   TEXT,
    geom     GEOMETRY(MultiPoint, 4326)
);

INSERT INTO poi (osm_id, name, amenity, shop, office, geom) VALUES ('node/13524647371', 'Роспак', NULL, NULL, 'company', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Point", "coordinates": [50.1950882, 53.2202994]}'), 4326)));
INSERT INTO poi (osm_id, name, amenity, shop, office, geom) VALUES ('node/1890131352', 'Пятёрочка', NULL, 'supermarket', NULL, ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Point", "coordinates": [50.2229629, 53.2346684]}'), 4326)));
INSERT INTO poi (osm_id, name, amenity, shop, office, geom) VALUES ('node/9675486227', 'Маяк', NULL, NULL, 'property_management', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Point", "coordinates": [50.2230956, 53.2346779]}'), 4326)));
INSERT INTO poi (osm_id, name, amenity, shop, office, geom) VALUES ('node/13524647372', 'Ателье', NULL, NULL, 'company', ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type": "Point", "coordinates": [50.2231376, 53.2347092]}'), 4326)));

CREATE INDEX IF NOT EXISTS idx_poi_geom ON poi USING GIST (geom);
