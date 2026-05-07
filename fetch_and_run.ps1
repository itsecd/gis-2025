# Запуск из корня проекта:
#   .\fetch_and_run.ps1

$baseUrl  = "https://overturemaps-us-west-2.s3.amazonaws.com"
$release  = "release/2026-04-15.0"
$prefix   = "$release/theme=buildings/type=building/"
$token    = $null
$keys     = [System.Collections.ArrayList]@()

Write-Host "Fetching partition list..."
do {
    $url = "${baseUrl}/?list-type=2&prefix=${prefix}&max-keys=1000"
    if ($token) { $url += "&continuation-token=$([Uri]::EscapeDataString($token))" }
    $xml  = [xml](Invoke-WebRequest -UseBasicParsing $url).Content
    foreach ($item in $xml.ListBucketResult.Contents) {
        [void]$keys.Add($item.Key)
    }
    $token = if ($xml.ListBucketResult.IsTruncated -eq 'true') {
        $xml.ListBucketResult.NextContinuationToken
    } else { $null }
} while ($token)

Write-Host "Found $($keys.Count) parquet files"

$urlList = ($keys | ForEach-Object { "    '${baseUrl}/$_'" }) -join ",`n"

$sql = @"
INSTALL spatial;
INSTALL httpfs;
LOAD spatial;
LOAD httpfs;

-- 3.1. Загрузка пользовательского GeoJSON
CREATE OR REPLACE TABLE my_buildings AS
SELECT
    feature ->> 'id' AS osm_id,
    ST_GeomFromGeoJSON((feature -> 'geometry')::VARCHAR) AS geom
FROM (SELECT unnest(features) AS feature FROM read_json('map.geojson'))
WHERE (feature -> 'geometry' ->> 'type') IN ('Polygon', 'MultiPolygon');

SELECT COUNT(*) AS my_buildings_loaded FROM my_buildings;

CREATE OR REPLACE VIEW user_bbox AS
SELECT
    MIN(ST_XMin(geom)) AS xmin, MIN(ST_YMin(geom)) AS ymin,
    MAX(ST_XMax(geom)) AS xmax, MAX(ST_YMax(geom)) AS ymax
FROM my_buildings;

-- 3.2. Подключение Overture Maps через HTTPS (партиции 2026-04-15.0)
-- Список партиций получен через S3 ListObjects API (без авторизации)
CREATE OR REPLACE TABLE overture_raw AS
SELECT
    id,
    ST_GeomFromWKB(geometry)        AS geom,
    sources,
    COALESCE(names.primary, '')     AS name,
    COALESCE(class, '')             AS class
FROM read_parquet([
$urlList
])
WHERE bbox.xmin <= (SELECT xmax FROM user_bbox)
  AND bbox.xmax >= (SELECT xmin FROM user_bbox)
  AND bbox.ymin <= (SELECT ymax FROM user_bbox)
  AND bbox.ymax >= (SELECT ymin FROM user_bbox);

SELECT COUNT(*) AS overture_buildings_loaded FROM overture_raw;

-- 3.3. Классификация источника
CREATE OR REPLACE TABLE overture_buildings AS
SELECT
    o.id, o.geom, o.name, o.class,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM my_buildings m WHERE ST_Intersects(o.geom, m.geom)
        ) THEN 'my'
        WHEN list_contains(
            list_transform(o.sources, s -> s.dataset), 'OpenStreetMap'
        ) THEN 'osm'
        ELSE 'ml'
    END AS source_type
FROM overture_raw o;

SELECT source_type, COUNT(*) AS cnt
FROM overture_buildings
GROUP BY source_type ORDER BY cnt DESC;

-- 3.4. Экспорт GeoJSON
COPY (
    SELECT id, source_type, class, name, geom FROM overture_buildings
) TO 'client/public/overture.geojson' WITH (FORMAT GDAL, DRIVER 'GeoJSON');

SELECT 'Done: client/public/overture.geojson' AS result;
"@

$sql | Out-File -FilePath "analysis.sql" -Encoding utf8
Write-Host "Running DuckDB (bbox pushdown — скачает только нужные row groups)..."
Get-Content analysis.sql | duckdb gis.duckdb
