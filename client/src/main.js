import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { applyStyle } from 'ol-mapbox-style';

// 🔧 FIX 1: Правильный путь к файлу стилей
import MAPBOX_STYLE from './overture-style.json';

// 🔧 FIX 2: Центр карты по вашим данным из input.json
// Ваши здания вокруг [50.336, 53.514]
const CENTER = fromLonLat([50.336, 53.514]);

// Источник данных overture.geojson
const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON(),
});

// Слой с применением стилей
const overtureLayer = new VectorLayer({ 
  source: overtureSource,
  zIndex: 2 
});

// Применяем стиль из overture-style.json
applyStyle(overtureLayer, MAPBOX_STYLE).catch(err => {
  console.warn('⚠️ Ошибка применения стиля:', err);
  
  // 🔧 FALLBACK: простой стиль если Mapbox не работает
  overtureLayer.setStyle(feature => {
    const src = feature.get('source_type');
    let color = '#808080';
    if (src === 'my') color = '#2ecc71';      // зелёный
    else if (src === 'osm') color = '#3498db'; // синий
    else if (src === 'ml') color = '#e67e22';  // оранжевый
    
    return new Style({
      fill: new Fill({ color: color + '99' }), // 60% opacity
      stroke: new Stroke({ color: '#222', width: 0.5 })
    });
  });
});

// Карта
const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM(), zIndex: 1 }),
    overtureLayer,
  ],
  view: new View({
    center: CENTER,
    zoom: 17,
    minZoom: 5,
    maxZoom: 22
  }),
});

// 🔧 FIX 3: Проверка что элементы существуют
const statsEl = document.getElementById('stats');
if (statsEl) {
  overtureSource.once('featuresloadend', () => {
    const features = overtureSource.getFeatures();
    const counts = { my: 0, osm: 0, ml: 0 };
    
    features.forEach(f => {
      const st = f.get('source_type');
      if (st in counts) counts[st]++;
    });
    
    statsEl.innerHTML =
      `Зданий: <span>${features.length}</span> &nbsp;|&nbsp; ` +
      `my: <span>${counts.my}</span> &nbsp;` +
      `osm: <span>${counts.osm}</span> &nbsp;` +
      `ml: <span>${counts.ml}</span>`;
  });
}

// Tooltip
const tooltip = document.getElementById('tooltip');
const SRC_LABELS = { my: 'Пользовательский', osm: 'OpenStreetMap', ml: 'ML' };
const SRC_COLORS = { my: '#22c55e', osm: '#3b82f6', ml: '#f97316' };

map.on('pointermove', (evt) => {
  if (evt.dragging) { 
    if (tooltip) tooltip.style.display = 'none'; 
    return; 
  }

  const feature = map.forEachFeatureAtPixel(evt.pixel, f => f, {
    layerFilter: l => l === overtureLayer,
    hitTolerance: 2,
  });

  if (!feature) {
    if (tooltip) tooltip.style.display = 'none';
    map.getViewport().style.cursor = '';
    return;
  }

  map.getViewport().style.cursor = 'pointer';

  const src  = feature.get('source_type') || '—';
  const name = feature.get('name')        || '—';
  const cls  = feature.get('class')       || '—';
  const h    = feature.get('height')      || '—';
  const fl   = feature.get('num_floors')  || '—';

  if (tooltip) {
    tooltip.innerHTML =
      `<strong style="color:${SRC_COLORS[src] || '#fff'}">${SRC_LABELS[src] || src}</strong>` +
      `Название: ${name}<br>` +
      `Класс: ${cls}<br>` +
      `Высота: ${h} м<br>` +
      `Этажей: ${fl}`;

    const [px, py] = evt.pixel;
    tooltip.style.left = `${px + 14}px`;
    tooltip.style.top  = `${py + 14}px`;
    tooltip.style.display = 'block';
  }
});

map.on('click', (evt) => {
  const feature = map.forEachFeatureAtPixel(evt.pixel, f => f, {
    layerFilter: l => l === overtureLayer,
    hitTolerance: 2,
  });
  if (feature) console.info('Overture id:', feature.get('id'));
});