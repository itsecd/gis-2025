"""Generate overture.geojson for Lab 3.

The script:
1) loads local GeoJSON buildings into DuckDB;
2) computes/uses a buffered bbox;
3) finds Overture Maps Buildings GeoParquet partitions intersecting that bbox;
4) reads only those partitions;
5) classifies buildings as my/osm/ml;
6) writes client/public/overture.geojson.
"""
from __future__ import annotations

import argparse
import json
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Iterable

import duckdb

RELEASE = "2026-04-15.0"
S3_BASE = f"s3://overturemaps-us-west-2/release/{RELEASE}/theme=buildings/type=building"


def bbox_from_geojson(path: Path, padding: float) -> tuple[float, float, float, float]:
    data = json.loads(path.read_text(encoding="utf-8"))
    xs: list[float] = []
    ys: list[float] = []

    def walk(coords):
        if isinstance(coords, list) and coords and isinstance(coords[0], (int, float)):
            xs.append(float(coords[0]))
            ys.append(float(coords[1]))
        elif isinstance(coords, list):
            for item in coords:
                walk(item)

    for feature in data.get("features", []):
        geom = feature.get("geometry") or {}
        walk(geom.get("coordinates", []))

    if not xs or not ys:
        raise ValueError(f"No coordinates found in {path}")
    return min(xs) - padding, min(ys) - padding, max(xs) + padding, max(ys) + padding


def connect(db_path: Path | str = ":memory:") -> duckdb.DuckDBPyConnection:
    con = duckdb.connect(str(db_path))
    for ext in ("spatial", "httpfs"):
        try:
            con.execute(f"LOAD {ext};")
        except Exception:
            con.execute(f"INSTALL {ext}; LOAD {ext};")
    con.execute("SET s3_region='us-west-2';")
    return con


def load_user_buildings(con: duckdb.DuckDBPyConnection, input_path: Path) -> int:
    p = input_path.as_posix().replace("'", "''")
    con.execute(f"""
        CREATE OR REPLACE TABLE user_buildings AS
        SELECT
            row_number() OVER () AS local_id,
            geom,
            id AS osm_id,
            building,
            "building:levels" AS building_levels,
            "addr:street" AS addr_street,
            "addr:housenumber" AS addr_housenumber,
            "addr:city" AS addr_city,
            "addr:postcode" AS addr_postcode
        FROM ST_Read('{p}')
        WHERE geom IS NOT NULL
    """)
    return con.execute("SELECT COUNT(*) FROM user_buildings").fetchone()[0]


def list_overture_files(con: duckdb.DuckDBPyConnection) -> list[str]:
    rows = con.execute(f"SELECT file FROM glob('{S3_BASE}/*.zstd.parquet')").fetchall()
    return [r[0] for r in rows]


def partition_intersects(url: str, bbox: tuple[float, float, float, float]) -> str | None:
    minx, miny, maxx, maxy = bbox
    c = duckdb.connect(":memory:")
    try:
        c.execute("LOAD httpfs;")
        c.execute("SET s3_region='us-west-2';")
        hit_x, hit_y = c.execute(f"""
            SELECT
                SUM(CASE WHEN path_in_schema = 'bbox, xmin'
                    AND TRY_CAST(stats_min_value AS DOUBLE) <= {maxx}
                    AND TRY_CAST(stats_max_value AS DOUBLE) >= {minx}
                    THEN 1 ELSE 0 END),
                SUM(CASE WHEN path_in_schema = 'bbox, ymin'
                    AND TRY_CAST(stats_min_value AS DOUBLE) <= {maxy}
                    AND TRY_CAST(stats_max_value AS DOUBLE) >= {miny}
                    THEN 1 ELSE 0 END)
            FROM parquet_metadata('{url}')
            WHERE path_in_schema IN ('bbox, xmin', 'bbox, ymin')
        """).fetchone()
        return url if (hit_x or 0) > 0 and (hit_y or 0) > 0 else None
    except Exception:
        return None
    finally:
        c.close()


def find_partitions(con: duckdb.DuckDBPyConnection, bbox: tuple[float, float, float, float]) -> list[str]:
    files = list_overture_files(con)
    selected: list[str] = []
    workers = min(32, max(1, os.cpu_count() or 4))
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = [pool.submit(partition_intersects, url, bbox) for url in files]
        for future in as_completed(futures):
            value = future.result()
            if value:
                selected.append(value)
    selected.sort()
    return selected


def load_overture(con: duckdb.DuckDBPyConnection, partitions: Iterable[str], bbox: tuple[float, float, float, float]) -> int:
    minx, miny, maxx, maxy = bbox
    files = list(partitions)
    if not files:
        raise RuntimeError("No Overture partitions intersect the bbox")
    file_list = ", ".join(f"'{u}'" for u in files)
    con.execute(f"""
        CREATE OR REPLACE TABLE overture_buildings AS
        SELECT
            id,
            geometry AS geom,
            sources,
            height,
            num_floors,
            class,
            names."primary" AS name
        FROM read_parquet([{file_list}], filename=true, hive_partitioning=1)
        WHERE bbox.xmin <= {maxx}
          AND bbox.xmax >= {minx}
          AND bbox.ymin <= {maxy}
          AND bbox.ymax >= {miny}
    """)
    return con.execute("SELECT COUNT(*) FROM overture_buildings").fetchone()[0]


def classify(con: duckdb.DuckDBPyConnection) -> list[tuple[str, int]]:
    con.execute("ALTER TABLE overture_buildings ADD COLUMN IF NOT EXISTS source_type VARCHAR")
    con.execute("""
        CREATE OR REPLACE TEMP TABLE my_intersections AS
        SELECT DISTINCT o.id
        FROM overture_buildings o
        JOIN user_buildings u
          ON ST_Intersects(o.geom, u.geom)
    """)
    con.execute("""
        UPDATE overture_buildings
        SET source_type = CASE
            WHEN id IN (SELECT id FROM my_intersections) THEN 'my'
            WHEN (
                SELECT bool_or(
                    s.dataset ILIKE '%openstreetmap%'
                    OR s.dataset ILIKE '%osm%'
                    OR s.record_id ILIKE '%openstreetmap%'
                )
                FROM unnest(sources) AS t(s)
            ) THEN 'osm'
            ELSE 'ml'
        END
    """)
    return con.execute("""
        SELECT source_type, COUNT(*) AS cnt
        FROM overture_buildings
        GROUP BY source_type
        ORDER BY cnt DESC
    """).fetchall()


def fallback_from_user(con: duckdb.DuckDBPyConnection) -> None:
    con.execute("""
        CREATE OR REPLACE TABLE overture_buildings AS
        SELECT
            COALESCE(osm_id, 'local_' || local_id::VARCHAR) AS id,
            geom,
            NULL AS sources,
            NULL::DOUBLE AS height,
            TRY_CAST(building_levels AS INTEGER) AS num_floors,
            COALESCE(building, 'building') AS class,
            NULL::VARCHAR AS name,
            'my' AS source_type
        FROM user_buildings
    """)


def export_geojson(con: duckdb.DuckDBPyConnection, out_path: Path) -> int:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    rows = con.execute("""
        SELECT
            ST_AsGeoJSON(geom) AS geometry,
            id,
            source_type,
            COALESCE(class, '') AS class,
            height,
            num_floors,
            COALESCE(name, '') AS name
        FROM overture_buildings
        WHERE geom IS NOT NULL
    """).fetchall()
    features = []
    for geom, id_, source_type, cls, height, num_floors, name in rows:
        features.append({
            "type": "Feature",
            "geometry": json.loads(geom),
            "properties": {
                "id": id_,
                "source_type": source_type,
                "class": cls,
                "height": height,
                "num_floors": num_floors,
                "name": name,
            },
        })
    out_path.write_text(json.dumps({"type": "FeatureCollection", "features": features}, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(features)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default="data/input.geojson", help="Input GeoJSON from Lab 1")
    parser.add_argument("--output", default="client/public/overture.geojson", help="Output GeoJSON for the client")
    parser.add_argument("--db", default="gis_lab3.duckdb", help="DuckDB database path")
    parser.add_argument("--padding", type=float, default=0.001, help="BBox padding in degrees")
    parser.add_argument("--offline-fallback", action="store_true", help="Create output from local buildings if Overture is unavailable")
    args = parser.parse_args()

    input_path = Path(args.input)
    out_path = Path(args.output)
    bbox = bbox_from_geojson(input_path, args.padding)
    print(f"BBox: minx={bbox[0]:.6f}, miny={bbox[1]:.6f}, maxx={bbox[2]:.6f}, maxy={bbox[3]:.6f}")

    con = connect(Path(args.db))
    user_count = load_user_buildings(con, input_path)
    print(f"Loaded local buildings: {user_count}")

    try:
        partitions = find_partitions(con, bbox)
        print(f"Selected Overture partitions: {len(partitions)}")
        overture_count = load_overture(con, partitions, bbox)
        print(f"Loaded Overture buildings in bbox: {overture_count}")
        print("Source stats:", classify(con))
    except Exception as exc:
        if not args.offline_fallback:
            con.close()
            raise
        print(f"WARNING: Overture query failed, using local fallback: {exc}")
        fallback_from_user(con)

    n = export_geojson(con, out_path)
    print(f"Written {n} features to {out_path}")
    con.close()


if __name__ == "__main__":
    main()
