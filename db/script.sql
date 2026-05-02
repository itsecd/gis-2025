INSTALL spatial;
INSTALL httpfs;

LOAD spatial;
LOAD httpfs;

CREATE TABLE IF NOT EXISTS osm_data as
SELECT * FROM ST_Read('..\gis-2026\map.geojson');

create table if not exists links as
WITH raw_data AS (
	SELECT *
	FROM 'https://stac.overturemaps.org/2026-04-15.0/buildings/building/collection.json'
),
raw_links AS (
	select unnest(links) as link
	from raw_data 
),
links as (
	select row_number() over () id, link.href
	from raw_links where link.type = 'application/geo+json'
),
raw_bboxes as (
	select unnest(extent.spatial.bbox) bbox from raw_data
),
bboxes as (
	select row_number() over () id, bbox[1] xmin, bbox[2] ymin, bbox[3] xmax, bbox[4] ymax from raw_bboxes
)
select href, xmin, ymin, xmax, ymax from links l join bboxes b on l.id=b.id ;




select distinct 'https://stac.overturemaps.org/2026-04-15.0/buildings/building/' || links.href link from links join osm_data on ST_Xmin(geom) between links.xmin and links.xmax and ST_Ymin(geom) between links.ymin and links.ymax;

select  assets.aws.alternate.s3.href from 'https://stac.overturemaps.org/2026-04-15.0/buildings/building/./00126/00126.json';


create table overture_data as
with osm_data_geom_bbox as (
	select ST_Extent_Agg(geom) geom from osm_data
),
osm_data_bbox as ( 
	select ST_Xmin(geom) as xmin, ST_Ymin(geom) as ymin, ST_Xmax(geom) as xmax, ST_Ymax(geom) as ymax from osm_data_geom_bbox
)
select * from read_parquet('s3://overturemaps-us-west-2/release/2026-04-15.0/theme=buildings/type=building/part-00126-a7a7933b-5151-59f6-80ee-2905400492cc-c000.zstd.parquet') data
join osm_data_bbox on ST_Xmin(geometry) between osm_data_bbox.xmin and osm_data_bbox.xmax and ST_Ymin(geometry) between osm_data_bbox.ymin and osm_data_bbox.ymax; 


select unnest(sources)  from overture_data ov left join osm_data osm on ST_Intersects(osm.geom, ST_SetCRS(ov.geometry, 'EPSG:4326')) where osm.building is not null;


create table if not exists overture_buildings
as select ov.*, CASE 
when exists (
	select 1 from osm_data osm where osm.building is not null and ST_Intersects(osm.geom, ST_SetCRS(ov.geometry, 'EPSG:4326'))
) then 'my'
when exists (
	select 1 from (select unnest(ov.sources) as src) where src.dataset = 'OpenStreetMap'
) then 'osm'
when exists (
	select 1 from (select unnest(ov.sources) as src) where lower(src.dataset) LIKE '%ml%' OR lower(src.dataset) LIKE '%microsoft%' OR lower(src.dataset) LIKE '%google%'
) then 'ml'
else 'ml'
end as source_type from overture_data ov;

copy (
	select geometry, source_type, id from overture_buildings
)
to '..\gis-2026\overture.geojson'
with (FORMAT GDAL, DRIVER 'GeoJSON');



