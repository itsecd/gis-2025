#!/usr/bin/env python3
import json
import sys
from pathlib import Path

INPUT = Path(sys.argv[1] if len(sys.argv) > 1 else "data/input.geojson")
OUTPUT = Path(sys.argv[2] if len(sys.argv) > 2 else "init-db/01_init.sql")

def sql_quote(value):
    if value is None:
        return "NULL"
    return "'" + str(value).replace("'", "''") + "'"

def prop(props, *names):
    for name in names:
        if name in props and props[name] not in (None, ""):
            return props[name]
    return None

def is_building(feature):
    props = feature.get("properties") or {}
    geom_type = (feature.get("geometry") or {}).get("type")
    return prop(props, "building") is not None and geom_type in {"Polygon", "MultiPolygon"}

def is_road(feature):
    props = feature.get("properties") or {}
    geom_type = (feature.get("geometry") or {}).get("type")
    return prop(props, "highway") is not None and geom_type in {"LineString", "MultiLineString"}

def is_poi(feature):
    props = feature.get("properties") or {}
    geom_type = (feature.get("geometry") or {}).get("type")
    return geom_type == "Point" and (prop(props, "amenity") is not None or prop(props, "name") is not None)

def geom_sql(geometry, multi=False):
    gj = json.dumps(geometry, ensure_ascii=False, separators=(",", ":"))
    base = f"ST_SetSRID(ST_GeomFromGeoJSON({sql_quote(gj)}), 4326)"
    return f"ST_Multi({base})" if multi else base

def osm_id(feature, props):
    return feature.get("id") or prop(props, "id", "osm_id", "osm:id")

def main():
    if not INPUT.exists():
        raise SystemExit(f"Не найден файл {INPUT}. Положите GeoJSON из 1 лабораторной в data/input.geojson")

    data = json.loads(INPUT.read_text(encoding="utf-8-sig"))
    features = data.get("features", [])

    buildings = [f for f in features if is_building(f)]
    roads = [f for f in features if is_road(f)]
    poi = [f for f in features if is_poi(f)]

    lines = []
    lines.append("CREATE EXTENSION IF NOT EXISTS postgis;\n")
    lines.append("DROP TABLE IF EXISTS buildings CASCADE;")
    lines.append("DROP TABLE IF EXISTS roads CASCADE;")
    lines.append("DROP TABLE IF EXISTS poi CASCADE;\n")

    lines.append("""CREATE TABLE buildings (
  id SERIAL PRIMARY KEY,
  osm_id TEXT,
  building TEXT,
  building_levels TEXT,
  addr_city TEXT,
  addr_street TEXT,
  addr_housenumber TEXT,
  name TEXT,
  geom GEOMETRY(MULTIPOLYGON, 4326)
);""")
    for f in buildings:
        p = f.get("properties") or {}
        values = [
            sql_quote(osm_id(f, p)),
            sql_quote(prop(p, "building")),
            sql_quote(prop(p, "building:levels", "building_levels")),
            sql_quote(prop(p, "addr:city", "addr_city")),
            sql_quote(prop(p, "addr:street", "addr_street")),
            sql_quote(prop(p, "addr:housenumber", "addr_housenumber")),
            sql_quote(prop(p, "name")),
            geom_sql(f["geometry"], multi=True),
        ]
        lines.append("INSERT INTO buildings (osm_id, building, building_levels, addr_city, addr_street, addr_housenumber, name, geom) VALUES (" + ", ".join(values) + ");")
    lines.append("CREATE INDEX idx_buildings_geom ON buildings USING GIST (geom);\n")

    lines.append("""CREATE TABLE roads (
  id SERIAL PRIMARY KEY,
  osm_id TEXT,
  name TEXT,
  highway TEXT,
  geom GEOMETRY(MULTILINESTRING, 4326)
);""")
    for f in roads:
        p = f.get("properties") or {}
        values = [
            sql_quote(osm_id(f, p)),
            sql_quote(prop(p, "name")),
            sql_quote(prop(p, "highway")),
            geom_sql(f["geometry"], multi=True),
        ]
        lines.append("INSERT INTO roads (osm_id, name, highway, geom) VALUES (" + ", ".join(values) + ");")
    lines.append("CREATE INDEX idx_roads_geom ON roads USING GIST (geom);\n")

    lines.append("""CREATE TABLE poi (
  id SERIAL PRIMARY KEY,
  osm_id TEXT,
  name TEXT,
  amenity TEXT,
  geom GEOMETRY(POINT, 4326)
);""")
    for f in poi:
        p = f.get("properties") or {}
        values = [
            sql_quote(osm_id(f, p)),
            sql_quote(prop(p, "name")),
            sql_quote(prop(p, "amenity")),
            geom_sql(f["geometry"], multi=False),
        ]
        lines.append("INSERT INTO poi (osm_id, name, amenity, geom) VALUES (" + ", ".join(values) + ");")
    lines.append("CREATE INDEX idx_poi_geom ON poi USING GIST (geom);\n")

    lines.append(f"-- Imported features: buildings={len(buildings)}, roads={len(roads)}, poi={len(poi)}")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"SQL generated: {OUTPUT}")
    print(f"features: buildings={len(buildings)}, roads={len(roads)}, poi={len(poi)}")

if __name__ == "__main__":
    main()
