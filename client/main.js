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

const COLORS  = { my: '#10b981', osm: '#6366f1', ml: '#f59e0b' };
const STROKES = { my: '#059669', osm: '#4338ca', ml: '#d97706' };

const visible = new Set(['my', 'osm', 'ml']);

const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON(),
});
const overtureLayer = new VectorLayer({ source: overtureSource });

function applyVisible() {
  const layers = ['my', 'osm', 'ml'].flatMap(t => visible.has(t) ? [
    { id: `fill-${t}`, type: 'fill', source: 'overture',
      filter: ['==', ['get', 'source_type'], t],
      paint: { 'fill-color': COLORS[t], 'fill-opacity': 0.6 } },
    { id: `line-${t}`, type: 'line', source: 'overture',
      filter: ['==', ['get', 'source_type'], t],
      paint: { 'line-color': STROKES[t], 'line-width': 1.2 } },
  ] : []);
  applyStyle(overtureLayer, {
    version: 8,
    sources: { overture: { type: 'geojson', data: '/overture.geojson' } },
    layers,
  }, 'overture');
}

applyVisible();

document.querySelectorAll('.toggle').forEach(label => {
  label.querySelector('input').addEventListener('change', e => {
    e.target.checked ? visible.add(e.target.value) : visible.delete(e.target.value);
    label.classList.toggle('off', !e.target.checked);
    applyVisible();
  });
});

const map = new Map({
  target: 'map',
  layers: [new TileLayer({ source: new OSM() }), overtureLayer],
  view: new View({ center: fromLonLat([49.220, 53.597]), zoom: 15 }),
});

const statsEl = document.getElementById('stats');
overtureSource.once('featuresloadend', () => {
  const counts = { my: 0, osm: 0, ml: 0 };
  overtureSource.getFeatures().forEach(f => {
    const t = f.get('source_type');
    if (t in counts) counts[t]++;
  });
  const total = counts.my + counts.osm + counts.ml;
  statsEl.innerHTML =
    `Всего: <b>${total}</b><br>` +
    `my: <b>${counts.my}</b><br>` +
    `osm: <b>${counts.osm}</b><br>` +
    `ml: <b>${counts.ml}</b>`;
});

const tooltip = document.getElementById('tooltip');
map.on('pointermove', evt => {
  if (evt.dragging) { tooltip.style.display = 'none'; return; }
  const f = map.forEachFeatureAtPixel(evt.pixel, f => f, {
    layerFilter: l => l === overtureLayer, hitTolerance: 2,
  });
  if (!f) { tooltip.style.display = 'none'; map.getViewport().style.cursor = ''; return; }
  map.getViewport().style.cursor = 'pointer';
  const src = f.get('source_type') || '—';
  tooltip.innerHTML =
    `<strong style="color:${COLORS[src] || '#334155'}">${src}</strong>` +
    `${f.get('name') || '—'}<br>` +
    `Класс: ${f.get('class') || '—'}<br>` +
    `Высота: ${f.get('height') || '—'} м · Этажей: ${f.get('num_floors') || '—'}`;
  const [px, py] = evt.pixel;
  tooltip.style.cssText += `;left:${px + 12}px;top:${py + 12}px;display:block`;
});
