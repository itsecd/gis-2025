import 'ol/ol.css';
import './style.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { applyStyle } from 'ol-mapbox-style';

const SOURCE_TYPES = ['my', 'osm', 'ml'];
const visibleTypes = new Set(SOURCE_TYPES);

const styleTemplate = {
  version: 8,
  sources: {
    overture: {
      type: 'geojson',
      data: '/overture.geojson',
    },
  },
  layers: [
    {
      id: 'buildings-fill',
      type: 'fill',
      source: 'overture',
      paint: {
        'fill-color': [
          'match', ['get', 'source_type'],
          'my', '#22c55e',
          'osm', '#3b82f6',
          'ml', '#f97316',
          '#94a3b8',
        ],
        'fill-opacity': 0.72,
      },
    },
    {
      id: 'buildings-outline',
      type: 'line',
      source: 'overture',
      paint: {
        'line-color': [
          'match', ['get', 'source_type'],
          'my', '#15803d',
          'osm', '#1d4ed8',
          'ml', '#c2410c',
          '#475569',
        ],
        'line-width': 1.4,
      },
    },
  ],
};

function makeStyle() {
  return {
    ...styleTemplate,
    layers: styleTemplate.layers.map((layer) => ({
      ...layer,
      filter: ['in', ['get', 'source_type'], ['literal', [...visibleTypes]]],
    })),
  };
}

const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON(),
});

const overtureLayer = new VectorLayer({ source: overtureSource });
applyStyle(overtureLayer, makeStyle(), 'overture');

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    overtureLayer,
  ],
  view: new View({
    center: fromLonLat([49.211966, 53.599272]),
    zoom: 18,
  }),
});

const statsEl = document.querySelector('#stats');
const popup = document.querySelector('#popup');

function updateStats() {
  const counts = { my: 0, osm: 0, ml: 0, other: 0 };
  for (const feature of overtureSource.getFeatures()) {
    const type = feature.get('source_type');
    if (type in counts) counts[type] += 1;
    else counts.other += 1;
  }
  const total = Object.values(counts).reduce((acc, value) => acc + value, 0);
  statsEl.innerHTML = `
    <strong>Всего объектов:</strong> ${total}<br />
    <strong>my:</strong> ${counts.my}<br />
    <strong>osm:</strong> ${counts.osm}<br />
    <strong>ml:</strong> ${counts.ml}
  `;
}

overtureSource.on('featuresloadend', updateStats);
overtureSource.on('featuresloaderror', () => {
  statsEl.textContent = 'Не удалось загрузить /overture.geojson';
});

document.querySelectorAll('.source-toggle').forEach((input) => {
  input.addEventListener('change', () => {
    if (input.checked) visibleTypes.add(input.value);
    else visibleTypes.delete(input.value);
    applyStyle(overtureLayer, makeStyle(), 'overture');
  });
});

map.on('pointermove', (event) => {
  if (event.dragging) {
    popup.style.display = 'none';
    return;
  }
  const feature = map.forEachFeatureAtPixel(event.pixel, (item) => item, {
    layerFilter: (layer) => layer === overtureLayer,
    hitTolerance: 3,
  });

  if (!feature) {
    popup.style.display = 'none';
    map.getTargetElement().style.cursor = '';
    return;
  }

  map.getTargetElement().style.cursor = 'pointer';
  const type = feature.get('source_type') || '—';
  popup.innerHTML = `
    <strong>source_type: ${type}</strong><br />
    id: ${feature.get('id') || '—'}<br />
    class: ${feature.get('class') || '—'}<br />
    height: ${feature.get('height') || '—'}<br />
    floors: ${feature.get('num_floors') || '—'}
  `;
  popup.style.left = `${event.pixel[0] + 14}px`;
  popup.style.top = `${event.pixel[1] + 14}px`;
  popup.style.display = 'block';
});
