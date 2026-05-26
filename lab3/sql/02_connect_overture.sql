INSTALL spatial;
INSTALL httpfs;
LOAD spatial;
LOAD httpfs;

DROP TABLE IF EXISTS overture_partitions;
DROP TABLE IF EXISTS overture_buildings;

CREATE TABLE overture_partitions (
  partition_id VARCHAR PRIMARY KEY,
  xmin DOUBLE,
  ymin DOUBLE,
  xmax DOUBLE,
  ymax DOUBLE,
  parquet_url VARCHAR
);

INSERT INTO overture_partitions VALUES (
  '00444',
  44.88904571533203,
  52.329078674316406,
  53.29610824584961,
  55.5407829284668,
  'https://overturemapswestus2.blob.core.windows.net/release/2026-05-20.0/theme=buildings/type=building/part-00444-c758194f-8660-57f6-b660-6d7341d5c7fe-c000.zstd.parquet'
);

CREATE TABLE overture_buildings AS
SELECT
  id,
  sources,
  height,
  num_floors,
  names.primary AS name,
  geometry
FROM read_parquet(
  [
    'https://overturemapswestus2.blob.core.windows.net/release/2026-05-20.0/theme=buildings/type=building/part-00444-c758194f-8660-57f6-b660-6d7341d5c7fe-c000.zstd.parquet'
  ],
  filename = true
)
WHERE
  bbox.xmin <= 49.976201136663256
  AND bbox.xmax >= 49.97295625487238
  AND bbox.ymin <= 53.12894111483267
  AND bbox.ymax >= 53.12782088133087;
