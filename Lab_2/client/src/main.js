import 'ol/ol.css';
import './style.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { applyStyle } from 'ol-mapbox-style';

import MAPBOX_STYLE from './style.json';

const osmLayer = new TileLayer({
  source: new OSM(),
  visible: true,
  zIndex: 0
});

const buildingsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings',
      TILED: true,
      FORMAT: 'image/png',
      TRANSPARENT: true
    },
    ratio: 1,
    serverType: 'geoserver'
  }),
  visible: true,
  zIndex: 1
});

const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:roads',
      TILED: true,
      FORMAT: 'image/png',
      TRANSPARENT: true
    },
    ratio: 1,
    serverType: 'geoserver'
  }),
  visible: true,
  zIndex: 2
});

const poiLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:poi',
      TILED: true,
      FORMAT: 'image/png',
      TRANSPARENT: true
    },
    ratio: 1,
    serverType: 'geoserver'
  }),
  visible: false,
  zIndex: 3
});

// ===================== OVERTURE LAYER (Mapbox Style) =====================
const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON()
});

const overtureLayer = new VectorLayer({
  source: overtureSource,
  visible: true,
  zIndex: 4
});

applyStyle(overtureLayer, MAPBOX_STYLE, 'overture');

const layers = {
  osm: osmLayer,
  roads: roadsLayer,
  buildings: buildingsLayer,
  poi: poiLayer,
  overture: overtureLayer
};

const center = fromLonLat([106.38, 52.79]);

const map = new Map({
  target: 'map',
  layers: [osmLayer, buildingsLayer, roadsLayer, poiLayer, overtureLayer],
  view: new View({
    center: center,
    zoom: 14,
    maxZoom: 19,
    minZoom: 10
  })
});

// ===================== ПАНЕЛЬ СТАТИСТИКИ =====================
const statsEl = document.getElementById('stats');

if (statsEl) {
  overtureSource.once('featuresloadend', () => {
    const features = overtureSource.getFeatures();
    const counts = { my: 0, osm: 0, ml: 0 };
    features.forEach(f => {
      const st = f.get('source_type');
      if (st in counts) counts[st]++;
    });
    statsEl.innerHTML = `
      <strong> Overture Buildings</strong><br>
      Всего: ${features.length} | 
      my: <span style="color:#22c55e">${counts.my}</span> | 
      osm: <span style="color:#3b82f6">${counts.osm}</span> | 
      ml: <span style="color:#f97316">${counts.ml}</span>
    `;
  });
}

// ===================== TOOLTIP ПРИ НАВЕДЕНИИ =====================
const tooltip = document.getElementById('tooltip');

const SRC_LABELS = { my: 'Пользовательский', osm: 'OpenStreetMap', ml: 'Машинное обучение' };
const SRC_COLORS = { my: '#22c55e', osm: '#3b82f6', ml: '#f97316' };

map.on('pointermove', (evt) => {
  if (!tooltip) return;
  
  if (evt.dragging) {
    tooltip.style.display = 'none';
    return;
  }

  const feature = map.forEachFeatureAtPixel(evt.pixel, f => f, {
    layerFilter: l => l === overtureLayer,
    hitTolerance: 2
  });

  if (!feature) {
    tooltip.style.display = 'none';
    map.getViewport().style.cursor = '';
    return;
  }

  map.getViewport().style.cursor = 'pointer';

  const src = feature.get('source_type') || '—';
  const name = feature.get('name') || '—';
  const cls = feature.get('class') || '—';
  const h = feature.get('height') || '—';
  const fl = feature.get('num_floors') || '—';

  tooltip.innerHTML = `
    <strong style="color:${SRC_COLORS[src] || '#fff'}">${SRC_LABELS[src] || src}</strong><br>
     Название: ${name}<br>
     Класс: ${cls}<br>
     Высота: ${h} м<br>
     Этажей: ${fl}
  `;

  const [px, py] = evt.pixel;
  tooltip.style.left = `${px + 14}px`;
  tooltip.style.top = `${py + 14}px`;
  tooltip.style.display = 'block';
});

// ===================== КЛИК ДЛЯ ОТЛАДКИ =====================
map.on('click', (evt) => {
  const feature = map.forEachFeatureAtPixel(evt.pixel, f => f, {
    layerFilter: l => l === overtureLayer,
    hitTolerance: 2
  });
  if (feature) {
    console.log('Overture building id:', feature.get('id'));
  }
});

// ===================== УПРАВЛЕНИЕ СЛОЯМИ =====================
document.addEventListener('DOMContentLoaded', () => {
  const toggles = ['osm', 'roads', 'buildings', 'poi'];
  
  toggles.forEach(layerName => {
    const toggle = document.getElementById(`toggle-${layerName}`);
    if (toggle) {
      toggle.checked = layers[layerName].getVisible();
      toggle.addEventListener('change', (e) => {
        switch(layerName) {
          case 'osm':
            layers.osm.setVisible(e.target.checked);
            break;
          case 'roads':
            layers.roads.setVisible(e.target.checked);
            break;
          case 'buildings':
            layers.buildings.setVisible(e.target.checked);
            break;
          case 'poi':
            layers.poi.setVisible(e.target.checked);
            break;
          default:
            console.log(`Неизвестный слой: ${layerName}`);
        }
      });
    }
  });
  
  const layerList = document.querySelector('.layer-list');
  if (layerList && !document.getElementById('toggle-overture')) {
    const overtureItem = document.createElement('label');
    overtureItem.className = 'layer-item';
    overtureItem.innerHTML = `
      <input type="checkbox" id="toggle-overture" checked />
      <span class="layer-name">
        <span class="color-dot" style="background: #2ecc71; box-shadow: 0 2px 4px rgba(46, 204, 113, 0.3);"></span>
        Overture Buildings
      </span>
      <span class="layer-badge">источники</span>
    `;
    layerList.appendChild(overtureItem);
    
    const toggleOverture = document.getElementById('toggle-overture');
    if (toggleOverture) {
      toggleOverture.addEventListener('change', (e) => {
        overtureLayer.setVisible(e.target.checked);
      });
    }
  }
});