--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg110+2)
-- Dumped by pg_dump version 16.4 (Debian 16.4-1.pgdg110+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS postgis;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
    ogc_fid integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    version character varying,
    building character varying,
    "building:levels" character varying,
    "addr:street" character varying,
    "addr:city" character varying,
    id character varying,
    "user" character varying,
    changeset character varying,
    "addr:place" character varying,
    "addr:housenumber" character varying
);


--
-- Name: tmp_layer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_layer (
    ogc_fid integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    version character varying,
    building character varying,
    "building:levels" character varying,
    "addr:street" character varying,
    "addr:city" character varying,
    id character varying,
    "user" character varying,
    changeset character varying,
    "addr:place" character varying,
    "addr:housenumber" character varying
);


--
-- Name: tmp_layer_ogc_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tmp_layer_ogc_fid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmp_layer_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tmp_layer_ogc_fid_seq OWNED BY public.tmp_layer.ogc_fid;


--
-- Name: poi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poi (
    ogc_fid integer DEFAULT nextval('public.tmp_layer_ogc_fid_seq'::regclass) NOT NULL,
    geom public.geometry(MultiPoint,4326),
    version character varying,
    building character varying,
    "building:levels" character varying,
    "addr:street" character varying,
    "addr:city" character varying,
    id character varying,
    "user" character varying,
    changeset character varying,
    "addr:place" character varying,
    "addr:housenumber" character varying
);


--
-- Name: roads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roads (
    ogc_fid integer DEFAULT nextval('public.tmp_layer_ogc_fid_seq'::regclass) NOT NULL,
    geom public.geometry(MultiLineString,4326),
    version character varying,
    building character varying,
    "building:levels" character varying,
    "addr:street" character varying,
    "addr:city" character varying,
    id character varying,
    "user" character varying,
    changeset character varying,
    "addr:place" character varying,
    "addr:housenumber" character varying
);


--
-- Name: tmp_layer ogc_fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmp_layer ALTER COLUMN ogc_fid SET DEFAULT nextval('public.tmp_layer_ogc_fid_seq'::regclass);


--
-- Data for Name: buildings; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.buildings VALUES (1, '0106000020E61000000100000001030000000100000005000000461037E1CBFC4840CD5FD5845F904A402CE7FB77D1FC48408A2A2E5163904A4030F15B35CDFC4840BEA9876765904A40461077B4C7FC484040E11B7F61904A40461037E1CBFC4840CD5FD5845F904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-2', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '97');
INSERT INTO public.buildings VALUES (2, '0106000020E610000001000000010300000001000000050000004710675CA8FC4840CC4BCAAF71904A404710A73DA5FC484012BC847F6F904A404710A7FCA9FC48403661BDBA6C904A40461067CFADFC48406C91C30C6F904A404710675CA8FC4840CC4BCAAF71904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-6', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '80');
INSERT INTO public.buildings VALUES (3, '0106000020E61000000100000001030000000100000005000000461027BCA6FC4840283DB7836A904A40461027BFA3FC4840908DEFD967904A4046106721A7FC484079FD6A5266904A404610E761AAFC4840578F32E168904A40461027BCA6FC4840283DB7836A904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-8', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '96');
INSERT INTO public.buildings VALUES (4, '0106000020E61000000100000001030000000100000005000000732D46D3AEFC4840ECC9239866904A40D98E15D5AAFC484018E2AE8663904A40127449C6AEFC4840AF20BEAD61904A406389AEC4B2FC4840731721BF64904A40732D46D3AEFC4840ECC9239866904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-9', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '96');
INSERT INTO public.buildings VALUES (5, '0106000020E61000000100000001030000000100000005000000D5D8F8B89FFC4840A75D87FE74904A406A7CDF6C9CFC48403B32079B72904A40C55FA6269FFC48409AB8314071904A4019C1E972A2FC48408E7D9FA373904A40D5D8F8B89FFC4840A75D87FE74904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-11', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '80');
INSERT INTO public.buildings VALUES (6, '0106000020E6100000010000000103000000010000000500000063CFDC2A95FC4840EF87446F5C904A4041BF103798FC4840B08270675F904A40E2375E3E94FC4840ECD50EDF60904A40384D5B3291FC4840A939DDE65D904A4063CFDC2A95FC4840EF87446F5C904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-12', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '110');
INSERT INTO public.buildings VALUES (7, '0106000020E61000000100000001030000000100000005000000CDF1CC0AB5FC484048D0E44864904A409F188DD7B0FC4840B754AFF660904A403B6C4880B3FC48401CCBC7C05F904A4001D049B3B7FC4840081F1A1363904A40CDF1CC0AB5FC484048D0E44864904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-13', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '96');
INSERT INTO public.buildings VALUES (8, '0106000020E610000001000000010300000001000000050000009EBC6630D9FC484014D5776E75904A409EBC26FBD5FC484052EBF08772904A409FBC26D9D9FC48403F84ACC370904A409FBC265DDDFC48406ECBB3B773904A409EBC6630D9FC484014D5776E75904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-14', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '62');
INSERT INTO public.buildings VALUES (9, '0106000020E610000001000000010300000001000000050000003DE1447BF1FC484062722E676B904A4080152995ECFC48407937D60968904A409FE24B42EFFC4840C9FC9EA266904A40B324AA28F4FC48408398D4FF69904A403DE1447BF1FC484062722E676B904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-15', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '66');
INSERT INTO public.buildings VALUES (10, '0106000020E61000000100000001030000000100000005000000B7FCE5618DFC484076A8772481904A40C98E9FD489FC4840DA3917F37E904A40DBE408F48DFC4840CFB4AC8B7C904A407005458191FC48406CB426BD7E904A40B7FCE5618DFC484076A8772481904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-17', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '79');


--
-- Data for Name: poi; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: roads; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: tmp_layer; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tmp_layer VALUES (1, '0106000020E61000000100000001030000000100000005000000461037E1CBFC4840CD5FD5845F904A402CE7FB77D1FC48408A2A2E5163904A4030F15B35CDFC4840BEA9876765904A40461077B4C7FC484040E11B7F61904A40461037E1CBFC4840CD5FD5845F904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-2', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '97');
INSERT INTO public.tmp_layer VALUES (2, '0106000020E610000001000000010300000001000000050000004710675CA8FC4840CC4BCAAF71904A404710A73DA5FC484012BC847F6F904A404710A7FCA9FC48403661BDBA6C904A40461067CFADFC48406C91C30C6F904A404710675CA8FC4840CC4BCAAF71904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-6', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '80');
INSERT INTO public.tmp_layer VALUES (3, '0106000020E61000000100000001030000000100000005000000461027BCA6FC4840283DB7836A904A40461027BFA3FC4840908DEFD967904A4046106721A7FC484079FD6A5266904A404610E761AAFC4840578F32E168904A40461027BCA6FC4840283DB7836A904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-8', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '96');
INSERT INTO public.tmp_layer VALUES (4, '0106000020E61000000100000001030000000100000005000000732D46D3AEFC4840ECC9239866904A40D98E15D5AAFC484018E2AE8663904A40127449C6AEFC4840AF20BEAD61904A406389AEC4B2FC4840731721BF64904A40732D46D3AEFC4840ECC9239866904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-9', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '96');
INSERT INTO public.tmp_layer VALUES (5, '0106000020E61000000100000001030000000100000005000000D5D8F8B89FFC4840A75D87FE74904A406A7CDF6C9CFC48403B32079B72904A40C55FA6269FFC48409AB8314071904A4019C1E972A2FC48408E7D9FA373904A40D5D8F8B89FFC4840A75D87FE74904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-11', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '80');
INSERT INTO public.tmp_layer VALUES (6, '0106000020E6100000010000000103000000010000000500000063CFDC2A95FC4840EF87446F5C904A4041BF103798FC4840B08270675F904A40E2375E3E94FC4840ECD50EDF60904A40384D5B3291FC4840A939DDE65D904A4063CFDC2A95FC4840EF87446F5C904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-12', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '110');
INSERT INTO public.tmp_layer VALUES (7, '0106000020E61000000100000001030000000100000005000000CDF1CC0AB5FC484048D0E44864904A409F188DD7B0FC4840B754AFF660904A403B6C4880B3FC48401CCBC7C05F904A4001D049B3B7FC4840081F1A1363904A40CDF1CC0AB5FC484048D0E44864904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-13', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '96');
INSERT INTO public.tmp_layer VALUES (8, '0106000020E610000001000000010300000001000000050000009EBC6630D9FC484014D5776E75904A409EBC26FBD5FC484052EBF08772904A409FBC26D9D9FC48403F84ACC370904A409FBC265DDDFC48406ECBB3B773904A409EBC6630D9FC484014D5776E75904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-14', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '62');
INSERT INTO public.tmp_layer VALUES (9, '0106000020E610000001000000010300000001000000050000003DE1447BF1FC484062722E676B904A4080152995ECFC48407937D60968904A409FE24B42EFFC4840C9FC9EA266904A40B324AA28F4FC48408398D4FF69904A403DE1447BF1FC484062722E676B904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-15', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '66');
INSERT INTO public.tmp_layer VALUES (10, '0106000020E61000000100000001030000000100000005000000B7FCE5618DFC484076A8772481904A40C98E9FD489FC4840DA3917F37E904A40DBE408F48DFC4840CFB4AC8B7C904A407005458191FC48406CB426BD7E904A40B7FCE5618DFC484076A8772481904A40', '0', 'yes', '1', 'Солнечная улица', 'сельское поселение Воскресенка', 'way/-17', 'alexandragorbuntsova', '183022012', 'СТ Рассвет', '79');


--
-- Name: tmp_layer_ogc_fid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tmp_layer_ogc_fid_seq', 10, true);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (ogc_fid);


--
-- Name: poi poi_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poi
    ADD CONSTRAINT poi_pkey PRIMARY KEY (ogc_fid);


--
-- Name: roads roads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roads
    ADD CONSTRAINT roads_pkey PRIMARY KEY (ogc_fid);


--
-- Name: tmp_layer tmp_layer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmp_layer
    ADD CONSTRAINT tmp_layer_pkey PRIMARY KEY (ogc_fid);


--
-- Name: idx_buildings_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_buildings_geom ON public.buildings USING gist (geom);


--
-- Name: idx_poi_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_poi_geom ON public.poi USING gist (geom);


--
-- Name: idx_roads_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_roads_geom ON public.roads USING gist (geom);


--
-- Name: tmp_layer_geom_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmp_layer_geom_geom_idx ON public.tmp_layer USING gist (geom);


--
-- PostgreSQL database dump complete
--
