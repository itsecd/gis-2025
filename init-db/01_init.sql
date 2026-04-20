CREATE EXTENSION IF NOT EXISTS postgis;

-- ===================== DDL: Таблицы =====================

-- Здания (полигональные объекты)
DROP TABLE IF EXISTS buildings CASCADE;
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    osm_id TEXT UNIQUE NOT NULL,
    addr_city TEXT,
    addr_street TEXT,
    addr_housenumber TEXT,
    addr_postcode TEXT,
    building TEXT,
    building_levels TEXT,
    name TEXT,
    geom GEOMETRY(MultiPolygon, 4326) NOT NULL
);

-- Дороги (линейные объекты)
DROP TABLE IF EXISTS roads CASCADE;
CREATE TABLE roads (
    id SERIAL PRIMARY KEY,
    osm_id TEXT UNIQUE NOT NULL,
    name TEXT,
    highway TEXT,
    route TEXT,
    ref TEXT,
    maxspeed TEXT,
    geom GEOMETRY(MultiLineString, 4326) NOT NULL
);

-- POI (точечные объекты)
DROP TABLE IF EXISTS poi CASCADE;
CREATE TABLE poi (
    id SERIAL PRIMARY KEY,
    osm_id TEXT UNIQUE NOT NULL,
    name TEXT,
    category TEXT,
    geom GEOMETRY(Point, 4326) NOT NULL
);

-- ===================== DML: Здания =====================

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/154012961', NULL, 'Московская улица', '4', '678174', 'apartments', '4', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9655007 62.5356713, 113.9656996 62.5359633, 113.9654579 62.5359983, 113.965259 62.5357063, 113.9655007 62.5356713))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/154013164', NULL, 'Комсомольская улица', '31', '678174', 'apartments', '9', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9655563 62.5374808, 113.965684 62.5376682, 113.9653929 62.5377104, 113.9652652 62.537523, 113.9655563 62.5374808))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/154013186', NULL, 'улица Аммосова', '16', '678174', 'apartments', '5', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9656389 62.5372512, 113.9654063 62.5372849, 113.9647234 62.5362815, 113.9649455 62.5362519, 113.9649893 62.536315, 113.9650959 62.5364687, 113.9652043 62.5366249, 113.9652908 62.5367548, 113.965394 62.5368988, 113.9654039 62.5369125, 113.9655019 62.5370538, 113.9655949 62.5371877, 113.9656389 62.5372512))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/154013348', NULL, 'Московская улица', '39', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9656108 62.5362565, 113.9656686 62.5363414, 113.96547 62.5363701, 113.9654122 62.5362853, 113.9656108 62.5362565))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/154013517', NULL, 'Московская улица', '2', '678174', 'apartments', '4', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9646698 62.5362958, 113.9644238 62.5363314, 113.964089 62.5358401, 113.9643349 62.5358044, 113.9646698 62.5362958))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788699', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9618393 62.5368276, 113.9620202 62.536799, 113.9620987 62.5369045, 113.9619178 62.5369331, 113.9618393 62.5368276))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788742', NULL, 'улица Курченко', '6', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9627124 62.537, 113.9626452 62.5369022, 113.9630253 62.5368466, 113.9630925 62.5369444, 113.9627124 62.537))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788748', NULL, 'улица Курченко', '9', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9609251 62.5360245, 113.9608208 62.5359316, 113.9612498 62.5358291, 113.9613541 62.535922, 113.9609251 62.5360245))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788752', NULL, 'улица Фрунзе', '6/2', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9601057 62.5355544, 113.9600188 62.5354684, 113.9604737 62.5353707, 113.9605606 62.5354567, 113.9601057 62.5355544))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788772', NULL, 'улица Фрунзе', '20', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9566289 62.5359719, 113.9565514 62.5358599, 113.9570441 62.5357873, 113.9571217 62.5358994, 113.9566289 62.5359719))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788795', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9621047 62.5370953, 113.9620697 62.5370492, 113.962289 62.5370138, 113.962324 62.5370599, 113.9621047 62.5370953))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788809', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.961979 62.5367633, 113.9620219 62.5367565, 113.9620334 62.5367721, 113.9619904 62.5367788, 113.961979 62.5367633))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788814', NULL, 'улица Аммосова', '19', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9637533 62.5367764, 113.9637159 62.5367195, 113.9640053 62.536679, 113.9640428 62.5367358, 113.9637533 62.5367764))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788829', NULL, 'улица Курченко', '5', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9618503 62.5362986, 113.9620002 62.5361079, 113.9621571 62.5361341, 113.9620073 62.5363249, 113.9618503 62.5362986))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788840', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9591373 62.5358408, 113.9590546 62.5357168, 113.9592569 62.5356881, 113.9593396 62.5358121, 113.9591373 62.5358408))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788844', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9542252 62.5359412, 113.954127 62.5357815, 113.9542519 62.5357652, 113.9543501 62.5359249, 113.9542252 62.5359412))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788884', NULL, 'улица Бабушкина', '22', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9619386 62.5371035, 113.9618809 62.5370275, 113.9619843 62.5370108, 113.962042 62.5370869, 113.9619386 62.5371035))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788888', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9627135 62.535829, 113.9626729 62.5357717, 113.9634637 62.5356525, 113.9635043 62.5357098, 113.9627135 62.535829))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788906', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.960951 62.5358004, 113.96077 62.5356025, 113.9609775 62.5355622, 113.9611584 62.5357601, 113.960951 62.5358004))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788960', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9633358 62.5367793, 113.9632272 62.5365958, 113.9633663 62.5365783, 113.9634748 62.5367618, 113.9633358 62.5367793))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788975', NULL, 'улица Фрунзе', '2А', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9617521 62.5355596, 113.9616177 62.5353499, 113.9618292 62.535321, 113.9619636 62.5355308, 113.9617521 62.5355596))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187788987', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9611499 62.5363901, 113.961285 62.5362131, 113.9614685 62.5362429, 113.9613334 62.5364199, 113.9611499 62.5363901))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187789020', NULL, 'улица Фрунзе', '12', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9585097 62.5355905, 113.9584301 62.5354747, 113.958639 62.5354442, 113.9587185 62.53556, 113.9585097 62.5355905))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187789028', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9534703 62.5373513, 113.9534314 62.537276, 113.9536239 62.5372549, 113.9536628 62.5373302, 113.9534703 62.5373513))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187789031', NULL, 'улица Курченко', '3', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9625429 62.5361794, 113.962667 62.5360459, 113.9628591 62.5360839, 113.9627351 62.5362174, 113.9625429 62.5361794))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187789061', NULL, 'улица Курченко', '5/1', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9617831 62.5357813, 113.9617004 62.5356669, 113.9618524 62.5356435, 113.9619351 62.535758, 113.9617831 62.5357813))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187789092', NULL, 'улица Курченко', '12', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9618485 62.5370045, 113.9618121 62.5369474, 113.9619 62.5369355, 113.9619364 62.5369926, 113.9618485 62.5370045))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/187789119', NULL, 'улица Курченко', '1', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9631839 62.5362748, 113.963127 62.536189, 113.9632895 62.5361661, 113.9633463 62.5362519, 113.9631839 62.5362748))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/306147205', NULL, NULL, NULL, NULL, 'construction', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9650593 62.5355161, 113.9650164 62.5354369, 113.9648984 62.5354419, 113.9648018 62.5352885, 113.9652631 62.5352291, 113.9653597 62.5353553, 113.9652524 62.5353751, 113.9653221 62.5354839, 113.9650593 62.5355161))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427063', 'Мирный', 'улица Курченко', '21', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9574783 62.5372153, 113.9573764 62.5370669, 113.9575695 62.5370372, 113.9576661 62.5371881, 113.9574783 62.5372153))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427408', 'Мирный', '2-й Пионерский переулок', '10', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9583179 62.5367885, 113.9582508 62.536692, 113.9584144 62.5366698, 113.9584278 62.536692, 113.9584761 62.5366859, 113.9585298 62.5367588, 113.9583179 62.5367885))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427787', 'Мирный', '1-й Пионерский переулок', '6', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9587286 62.5361088, 113.9586761 62.5360332, 113.9588553 62.5360067, 113.9589078 62.5360823, 113.9587286 62.5361088))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427788', NULL, '1-й Пионерский переулок', '4', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9591621 62.5360407, 113.9591102 62.5359632, 113.9593418 62.5359302, 113.9593937 62.5360076, 113.9591621 62.5360407))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427789', 'Мирный', '1-й Пионерский переулок', '2', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.959638 62.5359726, 113.9595856 62.5358886, 113.9598181 62.5358578, 113.9598705 62.5359418, 113.959638 62.5359726))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427842', 'Мирный', '1-й Пионерский переулок', '8', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.95838 62.5361744, 113.9583225 62.5360848, 113.958532 62.5360562, 113.9585895 62.5361458, 113.95838 62.5361744))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427843', NULL, '1-й Пионерский переулок', '10', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.95791 62.5362307, 113.9578585 62.5361526, 113.9581169 62.5361163, 113.9581684 62.5361944, 113.95791 62.5362307))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/445427844', 'Мирный', '2-й Пионерский переулок', '7', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9582283 62.5365405, 113.9581677 62.5364513, 113.9583766 62.5364211, 113.9584372 62.5365103, 113.9582283 62.5365405))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/565911120', NULL, 'улица Бабушкина', '35', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9615934 62.5382944, 113.9613856 62.5383268, 113.9613453 62.5382719, 113.9614206 62.5382601, 113.9613453 62.5381576, 113.9614778 62.5381369, 113.9615934 62.5382944))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/575170040', NULL, 'Комсомольская улица', '43', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9623114 62.5382414, 113.9622866 62.5382056, 113.9621386 62.5382273, 113.9620897 62.5381565, 113.9623619 62.5381165, 113.9624356 62.5382232, 113.9623114 62.5382414))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/575170041', NULL, 'улица Бабушкина', '30', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9619418 62.5380792, 113.961893 62.5380068, 113.9621425 62.537971, 113.9621913 62.5380434, 113.9619418 62.5380792))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/575170042', NULL, NULL, NULL, NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9618726 62.53795, 113.9618149 62.5378665, 113.9619913 62.5378406, 113.962049 62.5379241, 113.9618726 62.53795))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/575170043', NULL, 'улица Лазо', '12', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.961778 62.5377392, 113.9617363 62.5376816, 113.9619461 62.5376493, 113.9619878 62.537707, 113.961778 62.5377392))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487321', NULL, 'улица Фрунзе', '19', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.958018 62.5352389, 113.9582889 62.5351919, 113.958341 62.5352558, 113.9580701 62.5353028, 113.958018 62.5352389))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487322', NULL, 'улица Фрунзе', '21', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9576327 62.5353013, 113.9577601 62.5352809, 113.9578104 62.5353476, 113.957683 62.535368, 113.9576327 62.5353013))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487323', NULL, 'улица Фрунзе', '23', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9573977 62.5354182, 113.9573226 62.5353322, 113.9574346 62.5353114, 113.9575097 62.5353974, 113.9573977 62.5354182))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487324', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9564764 62.5353437, 113.9566593 62.5353167, 113.9566958 62.5353694, 113.9565129 62.5353964, 113.9564764 62.5353437))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487325', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9563695 62.5355421, 113.9564822 62.5355229, 113.956511 62.535559, 113.9563984 62.5355782, 113.9563695 62.5355421))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487326', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9565062 62.535527, 113.9566282 62.5355066, 113.9566733 62.535564, 113.9565513 62.5355844, 113.9565062 62.535527))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487327', NULL, NULL, NULL, NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9566268 62.5354803, 113.9568012 62.5354494, 113.9568479 62.5355055, 113.9566736 62.5355364, 113.9566268 62.5354803))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487332', NULL, NULL, NULL, NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.956446 62.5351899, 113.9566794 62.5351614, 113.9567168 62.5352267, 113.9564834 62.5352551, 113.956446 62.5351899))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487333', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.956157 62.5352595, 113.9563072 62.5352409, 113.9563437 62.5353037, 113.9561935 62.5353223, 113.956157 62.5352595))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487335', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9556126 62.5353506, 113.9557762 62.5353308, 113.9558205 62.5354086, 113.9556568 62.5354284, 113.9556126 62.5353506))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487336', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9556818 62.5356874, 113.9556218 62.5355915, 113.9557794 62.5355706, 113.9558393 62.5356665, 113.9556818 62.5356874))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487337', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9551059 62.5357801, 113.9550538 62.5357093, 113.955137 62.5356962, 113.955189 62.5357671, 113.9551059 62.5357801))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487339', NULL, 'улица Лумумбы', '15', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9559158 62.5358579, 113.9561033 62.5358335, 113.9561689 62.5359408, 113.9559814 62.5359652, 113.9559158 62.5358579))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487340', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.95545 62.536035, 113.955391 62.5359559, 113.9555082 62.5359373, 113.9555672 62.5360165, 113.95545 62.536035))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487341', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9551271 62.5361067, 113.955044 62.536014, 113.9552101 62.5359823, 113.9552932 62.5360751, 113.9551271 62.5361067))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487342', NULL, 'улица Фрунзе', '30А', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.954477 62.5360454, 113.954697 62.5360058, 113.954758 62.536078, 113.9545381 62.5361175, 113.954477 62.5360454))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487343', NULL, 'Первомайская улица', '32А', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9541122 62.535701, 113.9540532 62.5356132, 113.9542847 62.5355801, 113.9543437 62.535668, 113.9541122 62.535701))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487352', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9540917 62.5359671, 113.954038 62.5358805, 113.9541631 62.535864, 113.9542167 62.5359506, 113.9540917 62.5359671))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/718487353', NULL, NULL, NULL, NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9540456 62.5359374, 113.9537994 62.5359679, 113.9536936 62.5357864, 113.9539383 62.535756, 113.9539737 62.5358168, 113.9540753 62.5358042, 113.9541063 62.5358572, 113.9540061 62.5358696, 113.9540456 62.5359374))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/854362962', NULL, '1-й Пионерский переулок', '14', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9568284 62.5364132, 113.9567702 62.5363278, 113.9568641 62.5363142, 113.9569223 62.5363996, 113.9568284 62.5364132))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/913385506', NULL, 'улица Аммосова', '12', NULL, 'retail', NULL, 'Айсберг', ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9641351 62.5356173, 113.9639024 62.5352758, 113.9641361 62.5352477, 113.964159 62.5352817, 113.9644817 62.5353368, 113.9646291 62.5355442, 113.9641351 62.5356173))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/913385507', 'Мирный', 'улица Аммосова', '11', NULL, 'commercial', NULL, 'Алгыс', ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9631295 62.5356056, 113.9629478 62.5353575, 113.9631592 62.5353246, 113.9633409 62.5355726, 113.9631295 62.5356056))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709031', NULL, 'улица Бабушкина', '15', NULL, 'yes', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9597649 62.535641, 113.9598273 62.5357323, 113.9596238 62.5357619, 113.9595614 62.5356706, 113.9597649 62.535641))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709032', NULL, '1-й Пионерский переулок', '5', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.958901 62.5358028, 113.9589448 62.5358668, 113.9587307 62.5358979, 113.9586869 62.535834, 113.958901 62.5358028))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709033', NULL, '1-й Пионерский переулок', '7', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9582031 62.5357484, 113.958263 62.535836, 113.9580413 62.5358683, 113.9579815 62.5357807, 113.9582031 62.5357484))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709034', NULL, '1-й Пионерский переулок', '9', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9579734 62.5358694, 113.9580201 62.5359377, 113.9577948 62.5359705, 113.9577481 62.5359022, 113.9579734 62.5358694))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709035', NULL, '1-й Пионерский переулок', '11', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9575968 62.5359115, 113.9576566 62.5359991, 113.9574852 62.536024, 113.9574254 62.5359364, 113.9575968 62.5359115))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709036', NULL, '1-й Пионерский переулок', '13', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9570586 62.5359958, 113.9571051 62.5360638, 113.9568925 62.5360947, 113.956846 62.5360267, 113.9570586 62.5359958))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709037', NULL, 'улица Фрунзе', '18', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9572127 62.5356662, 113.9572592 62.5357342, 113.9570427 62.5357657, 113.9569962 62.5356977, 113.9572127 62.5356662))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709038', NULL, 'улица Фрунзе', '14', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9581529 62.5355208, 113.9581994 62.5355888, 113.958045 62.5356113, 113.9579985 62.5355433, 113.9581529 62.5355208))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709039', NULL, 'улица Фрунзе', '10', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9590968 62.5353671, 113.9591578 62.5354564, 113.9589316 62.5354893, 113.9588706 62.5354, 113.9590968 62.5353671))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1266709040', NULL, 'улица Фрунзе', '8', NULL, 'detached', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9596265 62.5354322, 113.9596875 62.5355215, 113.9594823 62.5355513, 113.9594213 62.535462, 113.9596265 62.5354322))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971849', 'Мирный', 'улица Бабушкина', '19', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9600181 62.5361915, 113.9601705 62.5361713, 113.9602164 62.536245, 113.960064 62.5362652, 113.9600181 62.5361915))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971850', 'Мирный', '2-й Пионерский переулок', '3', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9593833 62.5363703, 113.9593529 62.5363235, 113.9596023 62.536289, 113.9596327 62.5363358, 113.9593833 62.5363703))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971851', 'Мирный', '2-й Пионерский переулок', '5', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9585451 62.5364618, 113.9584869 62.5363706, 113.9586296 62.5363512, 113.9586878 62.5364424, 113.9585451 62.5364618))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971852', 'Мирный', '2-й Пионерский переулок', '9', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.957818 62.5365958, 113.9577912 62.5365518, 113.9580034 62.5365244, 113.9580301 62.5365684, 113.957818 62.5365958))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971853', 'Мирный', '2-й Пионерский переулок', '4', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9587255 62.5366642, 113.958692 62.5366231, 113.9588515 62.5365955, 113.9588849 62.5366366, 113.9587255 62.5366642))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971854', 'Мирный', '2-й Пионерский переулок', '6', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9592232 62.5366233, 113.9591735 62.5365505, 113.9593089 62.5365308, 113.9593586 62.5366036, 113.9592232 62.5366233))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971855', 'Мирный', '2-й Пионерский переулок', '4', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9597071 62.5365256, 113.9596785 62.5364801, 113.9598059 62.536463, 113.9598346 62.5365085, 113.9597071 62.5365256))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971856', 'Мирный', 'улица Бабушкина', '21', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9601799 62.5364805, 113.9601433 62.5364098, 113.9602639 62.5363965, 113.9603005 62.5364672, 113.9601799 62.5364805))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971857', 'Мирный', 'улица Бабушкина', '23', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9603818 62.536797, 113.9603332 62.5367223, 113.960468 62.5367037, 113.9605166 62.5367784, 113.9603818 62.536797))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474971858', 'Мирный', 'улица Курченко', '11', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9599902 62.5368501, 113.9599617 62.5368073, 113.9600793 62.5367907, 113.9601078 62.5368335, 113.9599902 62.5368501))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474997044', 'Мирный', 'улица Курченко', '13', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9594203 62.536826, 113.9593388 62.5366998, 113.9594994 62.5366777, 113.959581 62.5368039, 113.9594203 62.536826))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474997045', 'Мирный', 'улица Курченко', '15', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9590129 62.5369687, 113.9589684 62.536891, 113.9590484 62.5368813, 113.9590929 62.536959, 113.9590129 62.5369687))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474997046', 'Мирный', 'улица Курченко', '17', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9584164 62.5370396, 113.9583746 62.5369805, 113.9585012 62.5369614, 113.958543 62.5370205, 113.9584164 62.5370396))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474997047', 'Мирный', 'улица Курченко', '19', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9580671 62.5370971, 113.9580272 62.5370166, 113.9581293 62.5370059, 113.9581692 62.5370863, 113.9580671 62.5370971))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1474997048', 'Мирный', '2-й Пионерский переулок', '10', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9575116 62.5368674, 113.9574728 62.53681, 113.957593 62.5367927, 113.9576318 62.5368501, 113.9575116 62.5368674))'), 4326)));

INSERT INTO buildings (osm_id, addr_city, addr_street, addr_housenumber, addr_postcode, building, building_levels, name, geom) VALUES
('way/1475536967', 'Мирный', '1-й Пионерский переулок', '12', NULL, 'house', NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('POLYGON((113.9576477 62.5363688, 113.9576011 62.5363032, 113.9577612 62.536279, 113.9578078 62.5363446, 113.9576477 62.5363688))'), 4326)));

-- ===================== DML: Дороги =====================

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('relation/7292288', 'Автобус 2: Фабрика № 3 - мкр Заречный', NULL, 'bus', '2', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9620549 62.5331696, 113.9621176 62.5332687, 113.9625719 62.5339364, 113.962794 62.5342627, 113.9631115 62.5347295, 113.9634707 62.535252, 113.9638302 62.5357858, 113.9641616 62.5363462, 113.9645291 62.5368646, 113.9646918 62.5370942, 113.9649107 62.5374519, 113.965164 62.5378148, 113.9652047 62.5378731, 113.9652479 62.5379381, 113.9659304 62.5389665, 113.9661495 62.5392967, 113.9666124 62.5399941, 113.9666456 62.5400442)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('relation/7292413', 'Автобус 2: мкр Заречный - Фабрика № 3', NULL, 'bus', '2', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9620549 62.5331696, 113.9621176 62.5332687, 113.9625719 62.5339364, 113.962794 62.5342627, 113.9631115 62.5347295, 113.9634707 62.535252, 113.9638302 62.5357858, 113.9641616 62.5363462, 113.9645291 62.5368646, 113.9646918 62.5370942, 113.9649107 62.5374519, 113.965164 62.5378148, 113.9652047 62.5378731, 113.9653371 62.5378557, 113.9659206 62.5377789, 113.9661652 62.5377428, 113.9672864 62.5375773, 113.9682728 62.5374316, 113.9701166 62.5371594, 113.970287 62.5371346, 113.9704956 62.5371051, 113.972935 62.5367599, 113.9729888 62.5367523, 113.9736497 62.5366588, 113.9748219 62.536493, 113.9752477 62.5364327, 113.9754856 62.536399)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('relation/14214525', 'Автобус 3: Верхний посёлок - мкр Заречный', NULL, 'bus', '3', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9620549 62.5331696, 113.9621176 62.5332687, 113.9625719 62.5339364, 113.962794 62.5342627, 113.9631115 62.5347295, 113.9634707 62.535252, 113.9638302 62.5357858, 113.9641616 62.5363462, 113.9645291 62.5368646, 113.9646918 62.5370942, 113.9649107 62.5374519, 113.965164 62.5378148, 113.9652047 62.5378731, 113.9652479 62.5379381, 113.9659304 62.5389665, 113.9661495 62.5392967, 113.9666124 62.5399941, 113.9666456 62.5400442)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('relation/14214526', 'Автобус 3: мкр Заречный - Верхний посёлок', NULL, 'bus', '3', NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9620549 62.5331696, 113.9621176 62.5332687, 113.9625719 62.5339364, 113.962794 62.5342627, 113.9631115 62.5347295, 113.9634707 62.535252, 113.9638302 62.5357858, 113.9641616 62.5363462, 113.9645291 62.5368646, 113.9646918 62.5370942, 113.9649107 62.5374519, 113.965164 62.5378148, 113.9652047 62.5378731, 113.9652479 62.5379381, 113.9659304 62.5389665, 113.9661495 62.5392967, 113.9666124 62.5399941, 113.9666456 62.5400442)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/27486541', 'улица Аммосова', 'secondary', NULL, NULL, 'RU:urban', ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9620549 62.5331696, 113.9621176 62.5332687, 113.9625719 62.5339364, 113.962794 62.5342627, 113.9631115 62.5347295, 113.9634707 62.535252, 113.9638302 62.5357858, 113.9641616 62.5363462, 113.9645291 62.5368646, 113.9646918 62.5370942, 113.9649107 62.5374519, 113.965164 62.5378148, 113.9652047 62.5378731)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/50560594', 'Московская улица', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9682015 62.535175, 113.9672175 62.5353132, 113.9657683 62.5355168, 113.9645172 62.5356898, 113.9638302 62.5357858)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/75872689', 'Комсомольская улица', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9652047 62.5378731, 113.9653371 62.5378557, 113.9659206 62.5377789, 113.9661652 62.5377428, 113.9672864 62.5375773, 113.9682728 62.5374316, 113.9701166 62.5371594, 113.970287 62.5371346, 113.9704956 62.5371051, 113.972935 62.5367599, 113.9729888 62.5367523, 113.9736497 62.5366588, 113.9748219 62.536493, 113.9752477 62.5364327, 113.9754856 62.536399)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/112129315', 'улица Бабушкина', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9586213 62.5336508, 113.959176 62.5344536, 113.9597409 62.5352093, 113.9600895 62.5357898, 113.9604204 62.5362786, 113.9607989 62.5368478, 113.9610519 62.537201, 113.9613781 62.5376055, 113.9618645 62.5383718, 113.9629064 62.5398225, 113.963309 62.5404457, 113.9635351 62.5407957, 113.9638495 62.5410842, 113.9644504 62.5418954, 113.9645593 62.5422596, 113.9644408 62.5423541, 113.9644193 62.5424254, 113.9646472 62.5426896, 113.9646986 62.5427542)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884836', 'улица Гагарина', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9692647 62.545262, 113.9691585 62.5452278, 113.9688374 62.5451245, 113.9686651 62.5450606, 113.9685299 62.5449905, 113.9684351 62.5449229, 113.9676834 62.5438728, 113.9675971 62.5438058, 113.9671857 62.5431778, 113.9669527 62.5428802, 113.96663 62.5424037, 113.9663277 62.5419995, 113.9658514 62.5412994, 113.9654923 62.5408383, 113.9644969 62.5395528, 113.9639171 62.5386819, 113.9635595 62.5381206)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884840', 'улица Курченко', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9641616 62.5363462, 113.9607989 62.5368478, 113.9601524 62.5369404, 113.9592974 62.5370791, 113.9576078 62.5373706, 113.9574929 62.5374017, 113.9573495 62.5374334, 113.9568188 62.5375454, 113.9558893 62.5377281, 113.9549718 62.5379051, 113.9543934 62.5379917)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884841', 'улица Лазо', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9646918 62.5370942, 113.9613781 62.5376055, 113.9578703 62.5381144, 113.9563149 62.5383457, 113.9551984 62.5385068)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884842', 'улица Лумумбы', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9553257 62.5341069, 113.9558384 62.5349624, 113.9562281 62.5356693, 113.9566888 62.5362649, 113.9570818 62.5367736, 113.9570316 62.5368938, 113.9570772 62.536995, 113.9573495 62.5374334, 113.9577892 62.5380457, 113.9578703 62.5381144, 113.9581015 62.5384009, 113.9582667 62.5385215, 113.9584218 62.5386698, 113.958544 62.5388079, 113.9585755 62.5388571)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884844', 'Первомайская улица', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9625719 62.5339364, 113.959176 62.5344536, 113.9558384 62.5349624, 113.9545365 62.5351229, 113.9540395 62.53518, 113.9536267 62.5353262, 113.9535559 62.5353336, 113.9531696 62.5353738, 113.9527715 62.5353976, 113.9523144 62.5354248)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884846', 'улица Фрунзе', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9631115 62.5347295, 113.9597409 62.5352093, 113.9562281 62.5356693, 113.9551036 62.5358765, 113.9548431 62.5359215, 113.9532331 62.5361535, 113.9521689 62.5363161)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884848', '1-й Пионерский переулок', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9600895 62.5357898, 113.959386 62.5358711, 113.9589997 62.5359338, 113.9566888 62.5362649)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/204884849', '2-й Пионерский переулок', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9604204 62.5362786, 113.9570818 62.5367736)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/354013309', NULL, 'service', NULL, NULL, '40', ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9649107 62.5374519, 113.9650497 62.5374319, 113.9653492 62.5373888, 113.9658738 62.5373133, 113.9658432 62.5372698, 113.9654573 62.5367226, 113.9651843 62.536317, 113.9651399 62.5362621, 113.9650525 62.5362204, 113.964941 62.5361892, 113.9648444 62.536154, 113.9647855 62.536116, 113.9645532 62.535747, 113.9645172 62.5356898)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/354013311', NULL, 'service', NULL, NULL, '40', ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9653492 62.5373888, 113.9649593 62.536806, 113.9646504 62.5368481, 113.9645291 62.5368646)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/354013312', NULL, 'service', NULL, NULL, '40', ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9654573 62.5367226, 113.9665942 62.5365598, 113.967594 62.5364167, 113.9686175 62.5362701, 113.9683214 62.5358504, 113.9684451 62.535616, 113.9682315 62.5352294, 113.9682015 62.535175)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/354013318', NULL, 'footway', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.968762 62.5351547, 113.9691847 62.5357793, 113.9694073 62.5361083, 113.9698291 62.5367316, 113.9698574 62.5367734, 113.970083 62.5371067, 113.9693097 62.5372169, 113.9692702 62.5372237, 113.9683185 62.5373607, 113.9682349 62.5373713, 113.9677375 62.5374435, 113.9672378 62.537516, 113.966988 62.5375522, 113.9661696 62.53767, 113.9661206 62.5376771, 113.9660037 62.5376939, 113.9652982 62.5377954, 113.9651402 62.5375643, 113.9650497 62.5374319, 113.9646504 62.5368481, 113.9639551 62.5358312, 113.9645532 62.535747, 113.9646768 62.5357296, 113.9656275 62.5355958, 113.9658056 62.5355707, 113.9662933 62.5355021, 113.9671728 62.5353784, 113.9672491 62.5353676, 113.9676165 62.5353159, 113.9679884 62.5352636, 113.9682315 62.5352294, 113.968762 62.5351547)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/354014144', NULL, 'footway', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9676165 62.5353159, 113.9681655 62.5355154, 113.9682671 62.5356865, 113.9674453 62.5358012, 113.9666883 62.5359068, 113.9665627 62.5359243, 113.9659082 62.5360157, 113.9649668 62.536147, 113.9646768 62.5357296)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/354014845', NULL, 'footway', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9660037 62.5376939, 113.9655544 62.5374429, 113.9652407 62.5374836, 113.9651402 62.5375643)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/496652201', 'Комсомольская улица', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9543585 62.5394819, 113.9569666 62.5390955, 113.9585755 62.5388571, 113.9604444 62.5385801, 113.9615815 62.5384155, 113.9618645 62.5383718, 113.9635595 62.5381206, 113.9650335 62.5378989, 113.9652047 62.5378731)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/496652206', 'улица Аммосова', 'secondary', NULL, NULL, 'RU:urban', ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9652047 62.5378731, 113.9652479 62.5379381, 113.9659304 62.5389665, 113.9661495 62.5392967, 113.9666124 62.5399941, 113.9666456 62.5400442)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/565081585', 'улица Фрунзе', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9568188 62.5375454, 113.9561677 62.5369217, 113.9560584 62.5368542, 113.9557507 62.5366644, 113.955706 62.5366368, 113.9549651 62.536077, 113.9548431 62.5359215)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/697043305', NULL, 'service', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9560584 62.5368542, 113.9555445 62.5370122, 113.9552787 62.5371373, 113.9550793 62.5372982, 113.9547359 62.5374004, 113.9542486 62.5374949)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/697043306', NULL, 'service', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9557507 62.5366644, 113.9549685 62.5368947, 113.9543427 62.5370607, 113.9537612 62.5371782)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/697043308', NULL, 'service', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9558893 62.5377281, 113.9554492 62.5373632)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/718487338', NULL, 'service', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9545365 62.5351229, 113.9548597 62.5356091, 113.9551036 62.5358765)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/718487356', NULL, 'service', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9539621 62.5357114, 113.9535559 62.5353336)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/922851430', NULL, 'footway', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9653756 62.5379174, 113.9652479 62.5379381, 113.9650789 62.5379656, 113.9650335 62.5378989, 113.9649931 62.5378394, 113.965164 62.5378148, 113.9652982 62.5377954, 113.9653371 62.5378557, 113.9653756 62.5379174, 113.9660226 62.5389544, 113.9667172 62.5399811, 113.9667495 62.5400288, 113.966788 62.5400851, 113.9668813 62.5400708)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/922851438', NULL, 'footway', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9653756 62.5379174, 113.9659581 62.5378376, 113.9701679 62.5372399)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/1066644995', NULL, 'service', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9627507 62.5353568, 113.9634707 62.535252)'), 4326)));

INSERT INTO roads (osm_id, name, highway, route, ref, maxspeed, geom) VALUES
('way/1066644996', 'Московская улица', 'residential', NULL, NULL, NULL, ST_Multi(ST_SetSRID(ST_GeomFromText('LINESTRING(113.9634707 62.535252, 113.9637233 62.5352159)'), 4326)));

-- ===================== DML: POI =====================

INSERT INTO poi (osm_id, name, category, geom) VALUES
('relation/14190119', 'Детский сад №2 "Сардаана"', 'kindergarten', ST_Centroid(ST_SetSRID(ST_GeomFromText('POLYGON((113.9655412 62.5366788, 113.9651745 62.5361368, 113.9667004 62.5359256, 113.9678828 62.5357619, 113.9682362 62.5362998, 113.9675779 62.5363924, 113.9655412 62.5366788))'), 4326)));

INSERT INTO poi (osm_id, name, category, geom) VALUES
('way/354019800', NULL, 'parking', ST_Centroid(ST_SetSRID(ST_GeomFromText('POLYGON((113.9652123 62.5373161, 113.9648497 62.5367765, 113.9649778 62.5367581, 113.9653404 62.5372978, 113.9652123 62.5373161))'), 4326)));

INSERT INTO poi (osm_id, name, category, geom) VALUES
('node/8536987512', 'Ветеринарная клиника', 'veterinary', ST_SetSRID(ST_GeomFromText('POINT(113.9648414 62.5362698)'), 4326));

-- ===================== Пространственные индексы =====================

CREATE INDEX idx_buildings_geom ON buildings USING GIST (geom);
CREATE INDEX idx_roads_geom ON roads USING GIST (geom);
CREATE INDEX idx_poi_geom ON poi USING GIST (geom);
