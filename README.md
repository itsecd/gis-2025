# Лабораторная работа №2

## Разработка веб-приложения для публикации геоданных на базе GeoServer

## Цель работы

Цель лабораторной работы — освоить полный цикл подготовки, публикации и визуализации геоданных с использованием PostGIS, GeoServer и веб-клиента на базе OpenLayers.

В рамках работы были выполнены следующие этапы:

- развёрнута инфраструктура с помощью Docker Compose;
- загружены пространственные данные в PostgreSQL/PostGIS;
- подготовлены отдельные таблицы для геообъектов;
- настроена публикация слоёв в GeoServer;
- разработан веб-клиент на Vite + OpenLayers;
- опубликованные слои подключены к карте через WMS.
---


## Запуск инфраструктуры

Для запуска PostGIS и GeoServer необходимо выполнить команду из корня проекта:

```bash
docker compose up -d
```

После запуска будут доступны сервисы:

| Сервис | Адрес |
|---|---|
| PostgreSQL/PostGIS | `localhost:5432` |
| GeoServer | `http://localhost:8080/geoserver` |

### Данные для подключения к PostgreSQL/PostGIS

```text
Host: localhost
Port: 5432
Database: gis
User: gisuser
Password: gispass
```

### Данные для входа в GeoServer

```text
Login: admin
Password: geoserver
```

---

## Инициализация базы данных

При запуске контейнера PostGIS автоматически выполняется SQL-скрипт:

```text
init-db/01_init.sql
```

Скрипт создаёт таблицы для хранения пространственных объектов:

- `buildings` — здания;
- `roads` — дороги;
- `poi` — точечные объекты.

Для таблиц создаются первичные ключи и пространственные индексы по геометрии.

Пример пространственного индекса:

```sql
CREATE INDEX idx_buildings_geom
ON buildings
USING gist (geom);
```

---

## Настройка GeoServer

В GeoServer используется рабочее пространство:

```text
Workspace: gis
Namespace URI: https://ssau.ru/gis
```

Хранилище данных подключается к PostGIS со следующими параметрами:

```text
Host: postgis
Port: 5432
Database: gis
Schema: public
User: gisuser
Password: gispass
```

Опубликованные слои:

```text
gis:buildings
gis:roads
gis:poi
```

Основной слой для отображения результата лабораторной работы:

```text
gis:buildings
```

---

## Запуск веб-клиента

Перед запуском необходимо перейти в папку клиента:

```bash
cd client
```

Установить зависимости:

```bash
npm install
```

Запустить проект:

```bash
npm run dev
```



## Результат выполнения работы

В результате выполнения лабораторной работы:

- подготовлен проект с Docker Compose;
- развернуты PostGIS и GeoServer;
- данные из GeoJSON загружены в PostGIS;
- созданы отдельные таблицы для геообъектов;
- опубликован слой зданий в GeoServer;
- разработан веб-клиент для отображения слоя через WMS;

---

