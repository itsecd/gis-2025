# Лабораторные работы по курсу "Анализ и безопасность геоданных"

Состав лабораторных работ:
1. [Оцифровка](https://github.com/itsecd/gis-2026/blob/main/Lab%201.md)
2. [Веб-публикация данных](https://github.com/itsecd/gis-2026/blob/main/Lab%202.md)
3. [Анализ и визуализация данных](https://github.com/itsecd/gis-2026/blob/main/Lab%203.md)

## Лабораторная работа 3

SQL-пайплайн находится в `lab3.sql`. Он загружает здания из `data/input.geojson` в DuckDB, читает нужную партицию Overture Maps Buildings из GeoParquet по HTTP, рассчитывает поле `source_type` и экспортирует итоговый слой в `client/public/data/overture.geojson`.

Запуск обработки:

```bash
duckdb lab3.duckdb < lab3.sql
```

Запуск клиента:

```bash
cd client
npm install
npm run dev
```
