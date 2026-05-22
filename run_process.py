"""
Лабораторная работа №3
Обработка данных через DuckDB + Overture Maps Python SDK.

Запуск: python run_process.py
Результат: client/public/overture.geojson
"""

import json
import os
import duckdb
import pyarrow as pa
import shapely
from shapely.wkb import loads as wkb_loads
from shapely.strtree import STRtree
from shapely.ops import unary_union
from overturemaps.core import record_batch_reader as overture_reader
from overturemaps.core import _get_files_from_stac
from overturemaps.models import BBox
from overturemaps.releases import get_latest_release

# ── Пути ──────────────────────────────────────────────────────────────────────
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
INPUT_GEOJSON = os.path.join(PROJECT_ROOT, "input.geojson")
OUTPUT_GEOJSON = os.path.join(PROJECT_ROOT, "client", "public", "overture.geojson")
DB_PATH = os.path.join(PROJECT_ROOT, "lab3.duckdb")

# Радиус кластеризации в градусах (~4 км): здания ближе этого расстояния
# объединяются в один кластер и запрашиваются одним bbox к Overture Maps.
CLUSTER_BUFFER_DEG = 0.05


def compute_cluster_bboxes(geoms: list) -> list:
    """
    Буферизует каждую геометрию на CLUSTER_BUFFER_DEG, объединяет
    пересекающиеся буферы и возвращает BBox для каждого кластера.
    Так автоматически разделяются, например, Самара и Лопатино.
    """
    if not geoms:
        return []
    buffered = [g.buffer(CLUSTER_BUFFER_DEG) for g in geoms]
    merged = unary_union(buffered)
    cluster_shapes = (
        list(merged.geoms)
        if merged.geom_type == "MultiPolygon"
        else [merged]
    )
    bboxes = []
    for cs in cluster_shapes:
        minx, miny, maxx, maxy = cs.bounds
        bboxes.append(BBox(
            xmin=round(minx, 6),
            ymin=round(miny, 6),
            xmax=round(maxx, 6),
            ymax=round(maxy, 6),
        ))
    return bboxes


def main():
    os.makedirs(os.path.join(PROJECT_ROOT, "client", "public"), exist_ok=True)

    release = get_latest_release()
    print(f"Используется релиз Overture Maps: {release}")

    # ── 3.1  Загрузка пользовательского GeoJSON в DuckDB ──────────────────────
    print("\n>>> 3.1  Загрузка пользовательских зданий из input.geojson...")
    con = duckdb.connect(DB_PATH)
    con.execute("LOAD spatial;")

    input_path = INPUT_GEOJSON.replace("\\", "/")
    con.execute("DROP TABLE IF EXISTS user_buildings;")
    con.execute(f"""
        CREATE TABLE user_buildings AS
        SELECT *
        FROM ST_Read('{input_path}')
        WHERE ST_GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON');
    """)

    count = con.execute("SELECT COUNT(*) FROM user_buildings").fetchone()[0]
    print(f"  Загружено полигональных объектов: {count}")

    # Проверяем тип геометрии (убеждаемся, что GEOMETRY)
    samples = con.execute(
        "SELECT id, ST_GeometryType(geom) FROM user_buildings LIMIT 3"
    ).fetchall()
    for sid, gtype in samples:
        print(f"    {sid} -> {gtype}")

    # Получаем WKB для shapely (для пространственного пересечения)
    user_wkbs = con.execute("SELECT ST_AsWKB(geom) FROM user_buildings").fetchall()
    user_geoms = [wkb_loads(bytes(row[0])) for row in user_wkbs]
    user_tree = STRtree(user_geoms)
    print(f"  Пространственный индекс STRtree построен для {len(user_geoms)} объектов")

    # ── Кластеризация пользовательских зданий ─────────────────────────────────
    # Нужна потому, что здания могут быть в разных районах (Самара, Лопатино…).
    # Один общий bbox покрыл бы ~100×60 км и скачал бы весь регион.
    print(f"\n>>> Кластеризация зданий (буфер {CLUSTER_BUFFER_DEG}°)...")
    cluster_bboxes = compute_cluster_bboxes(user_geoms)
    print(f"  Найдено кластеров: {len(cluster_bboxes)}")
    for i, cb in enumerate(cluster_bboxes):
        print(f"    Кластер {i+1}: lon {cb.xmin}..{cb.xmax}  lat {cb.ymin}..{cb.ymax}")

    # ── 3.2  Определение партиций Overture Maps для каждого кластера ──────────
    print(f"\n>>> 3.2  Поиск партиций Overture Maps...")

    all_batches = []
    all_partitions = []

    for i, bbox in enumerate(cluster_bboxes):
        print(f"\n  ── Кластер {i+1} ──────────────────────────────────")
        print(f"     bbox: {bbox.xmin},{bbox.ymin} → {bbox.xmax},{bbox.ymax}")

        # Используем STAC-каталог для точного определения пересекающихся партиций
        partition_s3_paths = _get_files_from_stac(
            theme="buildings",
            overture_type="building",
            bbox=bbox,
            release=release,
        )

        if not partition_s3_paths:
            print(f"     Партиции не найдены, пропуск.")
            continue

        print(f"     Найдено партиций: {len(partition_s3_paths)}")
        for p in partition_s3_paths:
            print(f"       {p.split('/')[-1]}")
        all_partitions.extend(partition_s3_paths)

        # Загрузка зданий из текущего кластера через SDK
        print(f"     Загрузка зданий...")
        reader = overture_reader(
            "building",
            bbox=bbox,
            release=release,
            stac=True,
        )
        if reader is None:
            print(f"     Ошибка чтения, пропуск.")
            continue

        cluster_batches = list(reader)
        cluster_rows = sum(b.num_rows for b in cluster_batches)
        print(f"     Зданий в кластере: {cluster_rows}")
        all_batches.extend(cluster_batches)

    if not all_batches:
        print("\nОшибка: данные Overture Maps не загружены. Завершение.")
        con.close()
        return

    print(f"\n  Итого партиций: {len(all_partitions)}")
    overture_table = pa.Table.from_batches(all_batches)
    print(f"  Итого зданий Overture Maps: {overture_table.num_rows}")

    # Регистрируем таблицу в DuckDB для дальнейшего SQL-анализа
    con.register("overture_arrow", overture_table)
    con.execute("DROP TABLE IF EXISTS overture_raw;")
    con.execute("""
        CREATE TABLE overture_raw AS
        SELECT
            id,
            ST_GeomFromWKB(geometry)  AS geom,
            sources,
            names.primary              AS name_primary,
            class,
            height,
            num_floors
        FROM overture_arrow;
    """)
    raw_count = con.execute("SELECT COUNT(*) FROM overture_raw").fetchone()[0]
    print(f"  Данные сохранены в таблицу overture_raw: {raw_count} строк")

    # ── 3.3  Пространственное пересечение и классификация source_type ─────────
    print("\n>>> 3.3  Классификация source_type...")

    overture_geoms_wkb = con.execute(
        "SELECT id, ST_AsWKB(geom) FROM overture_raw"
    ).fetchall()

    # my — пересекается с пользовательскими зданиями (STRtree для скорости)
    source_type_map = {}
    for feat_id, geom_wkb in overture_geoms_wkb:
        if geom_wkb is None:
            source_type_map[feat_id] = "ml"
            continue
        geom = wkb_loads(bytes(geom_wkb))
        candidates = user_tree.query(geom, predicate="intersects")
        source_type_map[feat_id] = "my" if len(candidates) > 0 else None

    # osm — источник содержит 'OpenStreetMap'
    osm_ids = con.execute("""
        SELECT id FROM overture_raw
        WHERE list_contains(
            list_transform(sources, s -> s.dataset),
            'OpenStreetMap'
        );
    """).fetchall()
    osm_id_set = {row[0] for row in osm_ids}

    # ml — всё остальное (Microsoft ML Buildings, Google и др.)
    for feat_id in source_type_map:
        if source_type_map[feat_id] is None:
            source_type_map[feat_id] = "osm" if feat_id in osm_id_set else "ml"

    dist = {"my": 0, "osm": 0, "ml": 0}
    for v in source_type_map.values():
        dist[v] += 1
    print(f"  my={dist['my']}  osm={dist['osm']}  ml={dist['ml']}")

    # Сохраняем source_type в DuckDB
    st_rows = list(source_type_map.items())
    con.execute("DROP TABLE IF EXISTS source_type_table;")
    con.execute("CREATE TABLE source_type_table (id VARCHAR, source_type VARCHAR);")
    con.executemany("INSERT INTO source_type_table VALUES (?, ?);", st_rows)

    con.execute("DROP TABLE IF EXISTS overture_buildings;")
    con.execute("""
        CREATE TABLE overture_buildings AS
        SELECT
            o.id,
            o.geom,
            s.source_type,
            COALESCE(o.name_primary, '')    AS name,
            COALESCE(o.class, '')           AS class,
            COALESCE(o.height, 0)::FLOAT    AS height,
            COALESCE(o.num_floors, 0)::INT  AS num_floors
        FROM overture_raw o
        JOIN source_type_table s ON o.id = s.id;
    """)

    # ── 3.4  Экспорт в GeoJSON ────────────────────────────────────────────────
    print(f"\n>>> 3.4  Экспорт в {OUTPUT_GEOJSON}...")

    out_path = OUTPUT_GEOJSON.replace("\\", "/")
    con.execute(f"""
        COPY (
            SELECT
                geom         AS geometry,
                id,
                source_type,
                name,
                class,
                height,
                num_floors
            FROM overture_buildings
        ) TO '{out_path}'
        WITH (FORMAT GDAL, DRIVER 'GeoJSON');
    """)

    with open(OUTPUT_GEOJSON, encoding="utf-8") as f:
        data = json.load(f)
    feat_count = len(data.get("features", []))
    print(f"  Записано объектов в GeoJSON: {feat_count}")
    print(f"\nGotovo! -> {OUTPUT_GEOJSON}")

    con.close()


if __name__ == "__main__":
    main()
