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
import TileWMS from 'ol/source/TileWMS';

const SOURCE_TYPES = ['my', 'osm', 'ml'];
const visibleTypes = new Set(SOURCE_TYPES);

const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON()
});

const overtureLayer = new VectorLayer({
  source: overtureSource
});

const geoserverLayer = new TileLayer({
  source: new TileWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings',
      TILED: true
    },
    serverType: 'geoserver',
    transition: 0
  })
});

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM()
    }),
    geoserverLayer,
    overtureLayer
  ],
  view: new View({
    center: fromLonLat([49.211966, 53.599272]),
    zoom: 18
  })
});

let mapboxStyle = null;

async function loadMapboxStyle() {
  const response = await fetch('/style.json');

  if (!response.ok) {
    throw new Error(`Не удалось загрузить style.json: ${response.status}`);
  }

  mapboxStyle = await response.json();
  applyCurrentStyle();
}

function buildFilteredStyle() {
  if (!mapboxStyle) {
    return null;
  }

  const visible = Array.from(visibleTypes);

  return {
    ...mapboxStyle,
    layers: mapboxStyle.layers.map((layer) => {
      if (layer.source === 'overture') {
        return {
          ...layer,
          filter: ['in', ['get', 'source_type'], ['literal', visible]]
        };
      }

      return layer;
    })
  };
}

function applyCurrentStyle() {
  const filteredStyle = buildFilteredStyle();

  if (!filteredStyle) {
    return;
  }

  applyStyle(overtureLayer, filteredStyle, 'overture');
}

function updateStats() {
  const statsEl = document.querySelector('#stats');

  if (!statsEl) {
    return;
  }

  const counts = {
    my: 0,
    osm: 0,
    ml: 0,
    other: 0
  };

  for (const feature of overtureSource.getFeatures()) {
    const type = feature.get('source_type');

    if (type in counts) {
      counts[type] += 1;
    } else {
      counts.other += 1;
    }
  }

  const total = Object.values(counts).reduce((sum, value) => sum + value, 0);

  statsEl.innerHTML = `
    <strong>Всего объектов:</strong> ${total}<br />
    <strong>my:</strong> ${counts.my}<br />
    <strong>osm:</strong> ${counts.osm}<br />
    <strong>ml:</strong> ${counts.ml}
  `;
}

function setupToggles() {
  document.querySelectorAll('.source-toggle').forEach((input) => {
    input.addEventListener('change', () => {
      if (input.checked) {
        visibleTypes.add(input.value);
      } else {
        visibleTypes.delete(input.value);
      }

      applyCurrentStyle();
    });
  });
}

function setupPopup() {
  const popup = document.querySelector('#popup');

  if (!popup) {
    return;
  }

  map.on('pointermove', (event) => {
    if (event.dragging) {
      popup.style.display = 'none';
      return;
    }

    const feature = map.forEachFeatureAtPixel(event.pixel, (item) => item, {
      layerFilter: (layer) => layer === overtureLayer,
      hitTolerance: 3
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
}

overtureSource.on('featuresloadend', updateStats);

overtureSource.on('featuresloaderror', () => {
  const statsEl = document.querySelector('#stats');

  if (statsEl) {
    statsEl.textContent = 'Не удалось загрузить /overture.geojson';
  }
});

loadMapboxStyle().catch((error) => {
  console.error(error);
});

setupToggles();
setupPopup();