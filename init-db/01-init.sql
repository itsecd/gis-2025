CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS buildings;
DROP TABLE IF EXISTS roads;
DROP TABLE IF EXISTS pois;
DROP TABLE IF EXISTS tmp_layer;

CREATE TABLE tmp_layer (
    osm_id text PRIMARY KEY,
    changeset text,
    building text,
    building_levels integer,
    height numeric,
    addr_city text,
    addr_place text,
    addr_postcode text,
    addr_street text,
    addr_housenumber text,
    amenity text,
    leisure text,
    highway text,
    surface text,
    name text,
    geom geometry(Geometry, 4326) NOT NULL
);

INSERT INTO tmp_layer (
    osm_id, changeset, building, building_levels, height, addr_city, addr_place,
    addr_postcode, addr_street, addr_housenumber, amenity, leisure, highway,
    surface, name, geom
) VALUES
('way/1521895545', '183175860', 'house', 2, 6, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '25', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6592396,53.2822369],[50.6592483,53.282191],[50.6592537,53.2821603],[50.6594407,53.2821706],[50.6594268,53.2822485],[50.6592396,53.2822369]]]}'), 4326)),
('way/1521895546', '183175860', 'house', 1, 3, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '27', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6592763,53.28238],[50.659307,53.2822939],[50.659428,53.2823017],[50.6593975,53.2823908],[50.6593449,53.2823866],[50.6592763,53.28238]]]}'), 4326)),
('way/1521895547', '183175860', 'house', 2, 6, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '23', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6590637,53.2822084],[50.6590832,53.2821462],[50.659191,53.2821567],[50.6591707,53.2822207],[50.6590637,53.2822084]]]}'), 4326)),
('way/1521895548', '183175860', 'house', 1, 3, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '19', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6585508,53.282227],[50.6585802,53.2821144],[50.6586706,53.2821223],[50.6586406,53.2822354],[50.6585508,53.282227]]]}'), 4326)),
('way/1521895549', '183175860', 'house', 2, 6, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '21', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6587677,53.2822093],[50.6587846,53.2821161],[50.6589184,53.2821252],[50.6588841,53.2822239],[50.6587677,53.2822093]]]}'), 4326)),
('way/1521895550', '183175860', 'house', 3, 9, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '17', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6581964,53.2822142],[50.6582232,53.2821693],[50.6581351,53.2821676],[50.6581055,53.2822078],[50.65795,53.2821959],[50.6579904,53.2820732],[50.6584273,53.2820921],[50.6584026,53.2821794],[50.6583647,53.282177],[50.6583439,53.2822245],[50.6581964,53.2822142]]]}'), 4326)),
('way/1521895551', '183175860', 'house', 1, 3, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '14', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6591522,53.282108],[50.6591488,53.2820015],[50.6592606,53.2819981],[50.6592606,53.2820387],[50.6592606,53.2821103],[50.6591522,53.282108]]]}'), 4326)),
('way/1521895552', '183175860', 'house', 2, 6, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '12', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6588508,53.2821042],[50.6588563,53.2819998],[50.6589509,53.2819999],[50.6589448,53.2820388],[50.658944,53.2821105],[50.6588508,53.2821042]]]}'), 4326)),
('way/1521895553', '183175860', 'house', 2, 6, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '10', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6584563,53.282015],[50.6584628,53.2819307],[50.6586215,53.2819376],[50.6586009,53.2820263],[50.6584563,53.282015]]]}'), 4326)),
('way/1521895554', '183175860', 'house', 2, 6, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '6', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6580591,53.2820086],[50.6580583,53.2819566],[50.6580578,53.2819187],[50.6582135,53.2819208],[50.6581992,53.2820118],[50.6580591,53.2820086]]]}'), 4326)),
('way/1521895555', '183175860', 'house', 2, 6, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '8', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6583347,53.2820549],[50.658325,53.2819377],[50.65843,53.2819373],[50.6584314,53.2820588],[50.6583347,53.2820549]]]}'), 4326)),
('way/1521895556', '183175860', 'house', 1, 3, 'Усть-Кинельский', 'СДТ Завода им. Фрунзе', '449003', '5-я линия', '14', NULL, NULL, NULL, NULL, 'Собственный дом', ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[50.6578965,53.2820331],[50.6578988,53.2819522],[50.6580583,53.2819566],[50.6580466,53.2820374],[50.6578965,53.2820331]]]}'), 4326));

CREATE TABLE buildings AS
SELECT
    osm_id,
    changeset,
    building,
    building_levels,
    height,
    addr_city,
    addr_place,
    addr_postcode,
    addr_street,
    addr_housenumber,
    ST_Multi(geom)::geometry(MultiPolygon, 4326) AS geom
FROM tmp_layer
WHERE building IS NOT NULL
  AND GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON');

ALTER TABLE buildings ADD PRIMARY KEY (osm_id);

CREATE TABLE roads AS
SELECT
    osm_id,
    name,
    highway,
    surface,
    ST_Multi(geom)::geometry(MultiLineString, 4326) AS geom
FROM tmp_layer
WHERE highway IS NOT NULL
  AND GeometryType(geom) IN ('LINESTRING', 'MULTILINESTRING');

ALTER TABLE roads ADD PRIMARY KEY (osm_id);

CREATE TABLE pois AS
SELECT
    osm_id,
    name,
    amenity,
    addr_city,
    addr_place,
    addr_street,
    addr_housenumber,
    geom::geometry(Point, 4326) AS geom
FROM tmp_layer
WHERE amenity IS NOT NULL
  AND GeometryType(geom) = 'POINT';

ALTER TABLE pois ADD PRIMARY KEY (osm_id);

CREATE INDEX idx_tmp_layer_geom ON tmp_layer USING gist (geom);
CREATE INDEX idx_buildings_geom ON buildings USING gist (geom);
CREATE INDEX idx_roads_geom ON roads USING gist (geom);
CREATE INDEX idx_pois_geom ON pois USING gist (geom);
