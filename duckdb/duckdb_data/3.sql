SET s3_region = 'us-west-2';

DROP TABLE IF EXISTS overture_data;
CREATE TABLE overture_data AS
SELECT *
FROM read_parquet(
    's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*.parquet',
    filename=true,
    hive_partitioning=1
) AS data
WHERE
    bbox.xmin BETWEEN 49.82 AND 49.86
    AND bbox.ymin BETWEEN 53.46 AND 53.49;