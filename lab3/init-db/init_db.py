import duckdb

con = duckdb.connect("lab3/lab3.duckdb")

con.execute("INSTALL spatial;")
con.execute("LOAD spatial;")
con.execute("INSTALL httpfs;")
con.execute("LOAD httpfs;")
con.execute("SET s3_region='us-west-2';")

print("расширения загружены")

# загрузка GeoJSON
con.execute("""
CREATE OR REPLACE TABLE my_buildings AS
SELECT *
FROM ST_Read('E:/СОХРАНЯТЬ/УЧЕБА/Geo/gis-2026/map_new.geojson')
""")

# только здания
con.execute("""
CREATE OR REPLACE TABLE my_buildings_only AS
SELECT *
FROM my_buildings
WHERE user = 'Beni_nika_007'
""")

print("здания готовы")

# bbox
bbox = con.execute("""
SELECT ST_Extent(geom) 
FROM my_buildings_only
""").fetchone()[0]

min_x = bbox['min_x']
min_y = bbox['min_y']
max_x = bbox['max_x']
max_y = bbox['max_y']

print("bbox:", bbox)

# Overture 
con.execute(f"""
CREATE OR REPLACE TABLE overture_buildings AS
SELECT *
FROM read_parquet(
    's3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/*',
    hive_partitioning=1
)
WHERE bbox.xmin <= {max_x}
  AND bbox.xmax >= {min_x}
  AND bbox.ymin <= {max_y}
  AND bbox.ymax >= {min_y}
""")

print("overture загружен")

# добавляем колонку
con.execute("""
ALTER TABLE overture_buildings 
ADD COLUMN source_type TEXT
""")


con.execute("""
UPDATE overture_buildings
       SET source_type = NULL;
""")

con.execute("""
UPDATE overture_buildings ob
SET source_type = 'my'
WHERE EXISTS (
    SELECT 1
    FROM my_buildings_only gd
    WHERE gd.user = 'Beni_nika_007'
        AND ST_Contains(
            gd.geom,
            ST_Centroid(ob.geometry)
        )
        AND ST_Area(gd.geom) < 0.000001
)
""")

con.execute("""
UPDATE overture_buildings
SET source_type = CASE
    WHEN CAST(sources AS VARCHAR) LIKE '%OpenStreetMap%' THEN 'osm'
    ELSE 'ml'
END
WHERE source_type IS NULL
""")

con.execute("""
COPY (
    SELECT 
        geom AS geometry,
        'my' AS source_type,
        uid AS id,
        NULL AS name,
        building AS class,
        NULL AS height,
        NULL AS level,
        NULL AS sources
    FROM my_buildings_only

    UNION ALL

    SELECT 
        geometry,
        source_type,
        id,
        names.primary AS name,
        class,
        height,
        level,
        CAST(sources AS VARCHAR) AS sources
    FROM overture_buildings
    WHERE source_type != 'my'  

) TO 'lab3/overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON')
""")