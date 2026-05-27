INSTALL spatial;
LOAD spatial;
INSTALL httpfs;
LOAD httpfs;

SET s3_region = 'us-west-2';

-- ЛР2 здания
DROP TABLE IF EXISTS lab2_buildings;
CREATE TABLE lab2_buildings AS
SELECT *
FROM st_read('E:/geo/gis-2026/lb3/data.geojson');

-- Сначала только нужные колонки + bbox-ограничение
DROP TABLE IF EXISTS overture_raw;
CREATE TABLE overture_raw AS
SELECT
  *,
  geometry AS geom
FROM read_parquet(
  's3://overturemaps-us-west-2/release/2026-05-20.0/theme=buildings/type=building/*',
  filename = TRUE,
  hive_partitioning = 1
)
WHERE
  bbox.xmax >= 49.20914 AND bbox.xmin <= 49.31299 AND
  bbox.ymax >= 53.58871 AND bbox.ymin <= 53.60430;

DROP TABLE IF EXISTS overture_buildings;
CREATE TABLE overture_buildings AS
SELECT * FROM overture_raw;

-- Вытаскиваем dataset из массива sources
DROP TABLE IF EXISTS overture_with_dataset;
CREATE TABLE overture_with_dataset AS
WITH src AS (
  SELECT
    o.*,
    (
      SELECT s.dataset
      FROM unnest(o.sources) AS t(s)
      LIMIT 1
    ) AS dataset
  FROM overture_buildings o
)
SELECT *
FROM src;

-- dataset -> source_type (osm/ml)
DROP TABLE IF EXISTS overture_src;
CREATE TABLE overture_src AS
SELECT
  *,
  CASE
    WHEN dataset ILIKE '%openstreetmap%' THEN 'osm'
    WHEN dataset ILIKE '%ml%'            THEN 'ml'
    ELSE 'osm'
  END AS source_type
FROM overture_with_dataset;

-- Добавляем my через spatial join c ЛР2
DROP TABLE IF EXISTS overture_tagged;
CREATE TABLE overture_tagged AS
WITH joined AS (
  SELECT
    o.*,
    m.OGC_FID AS my_id
  FROM overture_src o
  LEFT JOIN lab2_buildings m
    ON st_intersects(
      st_setcrs(o.geom, 'OGC:CRS84'),
      st_setcrs(m.geom, 'OGC:CRS84')
    )
)
SELECT
  *,
  CASE
    WHEN my_id IS NOT NULL THEN 'my'
    ELSE source_type
  END AS source_type_final
FROM joined;

-- Ограничение зоной Самары (bbox)
DROP TABLE IF EXISTS overture_samara;
CREATE TABLE overture_samara AS
SELECT *
FROM overture_tagged
WHERE
  st_x(st_pointn(st_exteriorring(geom), 1)) BETWEEN 49.20914 AND 49.31299
  AND
  st_y(st_pointn(st_exteriorring(geom), 1)) BETWEEN 53.58871 AND 53.60430;

-- Статистика по источникам (пример анализа)
SELECT source_type_final, count(*) AS cnt
FROM overture_samara
GROUP BY source_type_final;

-- Экспорт GeoJSON (можно вынести в отдельный шаг)
COPY (
  SELECT
    source_type_final AS source_type,
    id,
    geom
  FROM overture_samara
) TO 'E:/geo/gis-2026/lb3\client/public/overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON', LAYER_CREATION_OPTIONS 'WRITE_BBOX=YES');