LOAD spatial;

COPY (
  SELECT
    id,
    source_type,
    name,
    height,
    num_floors,
    sources[1].dataset AS source_dataset,
    geometry
  FROM overture_buildings
) TO 'overture.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');
