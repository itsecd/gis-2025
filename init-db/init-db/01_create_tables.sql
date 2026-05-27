CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS buildings (
    id SERIAL PRIMARY KEY,
    osm_id TEXT,
    name TEXT,
    building TEXT,
    addr_street TEXT,
    addr_housenumber TEXT,
    building_levels TEXT,
    geom GEOMETRY(MultiPolygon, 4326)
);

CREATE TABLE IF NOT EXISTS roads (
    id SERIAL PRIMARY KEY,
    osm_id TEXT,
    name TEXT,
    highway TEXT,
    surface TEXT,
    geom GEOMETRY(MultiLineString, 4326)
);

CREATE TABLE IF NOT EXISTS pois (
    id SERIAL PRIMARY KEY,
    osm_id TEXT,
    name TEXT,
    amenity TEXT,
    shop TEXT,
    addr_street TEXT,
    addr_housenumber TEXT,
    geom GEOMETRY(Point, 4326)
);

CREATE INDEX IF NOT EXISTS idx_buildings_geom ON buildings USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_roads_geom ON roads USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_pois_geom ON pois USING GIST (geom);