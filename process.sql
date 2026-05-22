-- =============================================================
-- Лабораторная работа №3
-- DuckDB + Overture Maps: загрузка, пространственный анализ,
-- экспорт GeoJSON
--
-- Требования:
--   DuckDB >= 1.0 с расширениями spatial и httpfs
--   Доступ к S3 (публичный бакет overturemaps-us-west-2)
--
-- Запуск из корня проекта:
--   duckdb lab3.duckdb < process.sql
-- =============================================================

-- Шаг 0: расширения
INSTALL spatial;
INSTALL httpfs;
LOAD spatial;
LOAD httpfs;

-- Публичный бакет Overture Maps (учётные данные не нужны)
SET s3_region          = 'us-west-2';
SET s3_url_style       = 'vhost';
SET s3_access_key_id   = '';
SET s3_secret_access_key = '';


-- ---------------------------------------------------------------
-- 3.1  Загрузка пользовательского GeoJSON в DuckDB
-- ---------------------------------------------------------------

SELECT '=== 3.1 Загрузка пользовательских зданий ===' AS step;

-- ST_Read читает GeoJSON через GDAL; фильтруем только полигоны
DROP TABLE IF EXISTS user_buildings;
CREATE TABLE user_buildings AS
SELECT *
FROM ST_Read('input.geojson')
WHERE ST_GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON');

-- Убеждаемся, что геометрия корректно приведена к типу GEOMETRY
SELECT id, ST_GeometryType(geom) AS geom_type
FROM user_buildings
LIMIT 5;

SELECT COUNT(*) AS user_building_count FROM user_buildings;


-- ---------------------------------------------------------------
-- 3.2  Подключение данных Overture Maps (GeoParquet, без скачивания)
-- ---------------------------------------------------------------

SELECT '=== 3.2 Bbox и кластеры пользовательских данных ===' AS step;

-- Общий bbox всех пользовательских зданий (для справки)
DROP VIEW IF EXISTS user_bbox;
CREATE VIEW user_bbox AS
SELECT
    MIN(ST_XMin(geom)) AS xmin,
    MIN(ST_YMin(geom)) AS ymin,
    MAX(ST_XMax(geom)) AS xmax,
    MAX(ST_YMax(geom)) AS ymax
FROM user_buildings;

SELECT 'Полный bbox пользовательских данных:' AS info;
SELECT * FROM user_bbox;

-- !! Важно: единый bbox охватывает ~100×60 км (от Лопатино до Самары),
--    поэтому делаем запросы по кластерам, разделяя районы по долготе.
--    Порог lon = 50.0: западнее — Лопатино (~49.4°), восточнее — Самара (~50.2°).

DROP TABLE IF EXISTS cluster_bboxes;
CREATE TABLE cluster_bboxes AS
WITH clustered AS (
    SELECT
        CASE
            WHEN ST_X(ST_Centroid(geom)) >= 50.0 THEN 'samara'
            ELSE 'lopytino'
        END AS cluster_name,
        geom
    FROM user_buildings
)
SELECT
    cluster_name,
    MIN(ST_XMin(geom)) - 0.01 AS xmin,
    MIN(ST_YMin(geom)) - 0.01 AS ymin,
    MAX(ST_XMax(geom)) + 0.01 AS xmax,
    MAX(ST_YMax(geom)) + 0.01 AS ymax
FROM clustered
GROUP BY cluster_name;

SELECT 'Bbox по кластерам:' AS info;
SELECT * FROM cluster_bboxes;

-- Определяем список партиций Overture Maps для каждого кластера.
-- DuckDB применяет predicate-pushdown по min/max-статистике Parquet:
-- только файлы, чьи row-group bbox перекрываются с нашим запросом,
-- будут прочитаны — это и есть «работа только с нужными партициями».
SELECT '=== Поиск пересекающихся партиций ===' AS step;

DROP TABLE IF EXISTS partition_files;
CREATE TABLE partition_files AS
SELECT DISTINCT filename, cluster_name
FROM read_parquet(
    's3://overturemaps-us-west-2/release/2026-05-20.0/theme=buildings/type=building/*.parquet',
    filename = true
)
CROSS JOIN cluster_bboxes cb
WHERE
    bbox.xmin <= cb.xmax AND
    bbox.xmax >= cb.xmin AND
    bbox.ymin <= cb.ymax AND
    bbox.ymax >= cb.ymin;

SELECT 'Партиции, пересекающиеся с bbox кластеров:' AS info;
SELECT cluster_name, filename FROM partition_files ORDER BY cluster_name;

-- Загружаем здания из найденных партиций (UNION ALL по кластерам)
SELECT '=== Загрузка зданий из партиций ===' AS step;

DROP TABLE IF EXISTS overture_raw;
CREATE TABLE overture_raw AS
-- Кластер Самара
SELECT
    id,
    ST_GeomFromWKB(geometry)  AS geom,
    sources,
    names.primary              AS name_primary,
    class,
    height,
    num_floors
FROM read_parquet(
    list(SELECT filename FROM partition_files WHERE cluster_name = 'samara')
), cluster_bboxes cb
WHERE cb.cluster_name = 'samara'
  AND bbox.xmin <= cb.xmax AND bbox.xmax >= cb.xmin
  AND bbox.ymin <= cb.ymax AND bbox.ymax >= cb.ymin

UNION ALL

-- Кластер Лопатино
SELECT
    id,
    ST_GeomFromWKB(geometry)  AS geom,
    sources,
    names.primary              AS name_primary,
    class,
    height,
    num_floors
FROM read_parquet(
    list(SELECT filename FROM partition_files WHERE cluster_name = 'lopytino')
), cluster_bboxes cb
WHERE cb.cluster_name = 'lopytino'
  AND bbox.xmin <= cb.xmax AND bbox.xmax >= cb.xmin
  AND bbox.ymin <= cb.ymax AND bbox.ymax >= cb.ymin;

SELECT COUNT(*) AS overture_raw_count FROM overture_raw;


-- ---------------------------------------------------------------
-- 3.3  Пространственное пересечение с пользовательскими данными
-- ---------------------------------------------------------------

SELECT '=== 3.3 Классификация source_type ===' AS step;

DROP TABLE IF EXISTS overture_buildings;
CREATE TABLE overture_buildings AS
SELECT
    o.id,
    o.geom,
    o.name_primary,
    o.class,
    o.height,
    o.num_floors,
    CASE
        -- 'my': объект пересекается с пользовательскими зданиями из Lab 1
        WHEN EXISTS (
            SELECT 1
            FROM user_buildings u
            WHERE ST_Intersects(o.geom, u.geom)
        ) THEN 'my'

        -- 'osm': источник — OpenStreetMap
        WHEN list_contains(
            list_transform(o.sources, s -> s.dataset),
            'OpenStreetMap'
        ) THEN 'osm'

        -- 'ml': автоматическое детектирование (Microsoft, Google и др.)
        ELSE 'ml'
    END AS source_type
FROM overture_raw o;

SELECT source_type, COUNT(*) AS cnt
FROM overture_buildings
GROUP BY source_type
ORDER BY cnt DESC;


-- ---------------------------------------------------------------
-- 3.4  Формирование итогового GeoJSON-слоя overture.geojson
-- ---------------------------------------------------------------

SELECT '=== 3.4 Экспорт в client/public/overture.geojson ===' AS step;

-- Директория client/public/ должна существовать до запуска скрипта
COPY (
    SELECT
        geom                          AS geometry,
        id,
        source_type,
        COALESCE(name_primary, '')    AS name,
        COALESCE(class, '')           AS class,
        COALESCE(height, 0)::FLOAT    AS height,
        COALESCE(num_floors, 0)::INT  AS num_floors
    FROM overture_buildings
) TO 'client/public/overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');

SELECT 'Готово! Файл: client/public/overture.geojson' AS result;
