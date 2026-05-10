-- public.buildings definition

-- Drop table

-- DROP TABLE public.buildings;

CREATE TABLE public.buildings (
	pk_id int4 NULL,
	"timestamp" timestamptz NULL,
	"version" varchar NULL,
	changeset varchar NULL,
	"user" varchar NULL,
	uid varchar NULL,
	"addr:city" varchar NULL,
	"addr:housenumber" varchar NULL,
	"addr:place" varchar NULL,
	"addr:postcode" varchar NULL,
	amenity varchar NULL,
	building varchar NULL,
	"building:levels" varchar NULL,
	crossing varchar NULL,
	footway varchar NULL,
	highway varchar NULL,
	landuse varchar NULL,
	"natural" varchar NULL,
	tactile_paving varchar NULL,
	tracktype varchar NULL,
	id varchar NULL,
	geom public.geometry(geometry, 4326) NULL
);
CREATE INDEX idx_buildings_geom ON public.buildings USING gist (geom);

-- public.roads definition

-- Drop table

-- DROP TABLE public.roads;

CREATE TABLE public.roads (
	pk_id int4 NULL,
	"timestamp" timestamptz NULL,
	"version" varchar NULL,
	changeset varchar NULL,
	"user" varchar NULL,
	uid varchar NULL,
	"addr:city" varchar NULL,
	"addr:housenumber" varchar NULL,
	"addr:place" varchar NULL,
	"addr:postcode" varchar NULL,
	amenity varchar NULL,
	building varchar NULL,
	"building:levels" varchar NULL,
	crossing varchar NULL,
	footway varchar NULL,
	highway varchar NULL,
	landuse varchar NULL,
	"natural" varchar NULL,
	tactile_paving varchar NULL,
	tracktype varchar NULL,
	id varchar NULL,
	geom public.geometry(geometry, 4326) NULL
);
CREATE INDEX idx_roads_geom ON public.roads USING gist (geom);