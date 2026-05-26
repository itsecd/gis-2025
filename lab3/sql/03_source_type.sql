LOAD spatial;

ALTER TABLE overture_buildings DROP COLUMN IF EXISTS source_type;
ALTER TABLE overture_buildings ADD COLUMN source_type VARCHAR;

UPDATE overture_buildings AS ob
SET source_type = CASE
  WHEN EXISTS (
    SELECT 1
    FROM user_buildings AS ub
    WHERE ST_Intersects(ob.geometry, ub.geom)
  ) THEN 'my'
  WHEN EXISTS (
    SELECT 1
    FROM unnest(ob.sources) AS s(source)
    WHERE lower(source.dataset) LIKE '%openstreetmap%'
       OR lower(source.dataset) LIKE '%osm%'
  ) THEN 'osm'
  WHEN EXISTS (
    SELECT 1
    FROM unnest(ob.sources) AS s(source)
    WHERE lower(source.dataset) LIKE '%microsoft%'
       OR lower(source.dataset) LIKE '%google%'
       OR lower(source.dataset) LIKE '%ml%'
  ) THEN 'ml'
  ELSE 'ml'
END;
