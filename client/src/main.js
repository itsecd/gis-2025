import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { stylefunction } from 'ol-mapbox-style';
import mapboxStyle from './style.json';

const WMS_URL = 'http://localhost:8080/geoserver/gis/wms';

function makeWmsLayer(layerName) {
  return new ImageLayer({
    source: new ImageWMS({
      url: WMS_URL,
      params: { LAYERS: layerName, TILED: true },
      ratio: 1,
      serverType: 'geoserver',
    }),
  });
}

const buildingsLayer = makeWmsLayer('gis:buildings');
const roadsLayer    = makeWmsLayer('gis:roads');
const poiLayer      = makeWmsLayer('gis:poi');

// ── Overture Maps слой с хороплетом по source_type ────────────────────────────
const overtureSource = new VectorSource({
  url: './overture.geojson',
  format: new GeoJSON(),
});

const overtureLayer = new VectorLayer({ source: overtureSource });

// Применяем Mapbox Style к VectorLayer
stylefunction(overtureLayer, mapboxStyle, 'overture');

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    overtureLayer,
    buildingsLayer,
    roadsLayer,
    poiLayer,
  ],
  view: new View({
    center: fromLonLat([50.196, 53.221]),
    zoom: 14,
  }),
});

// Управление видимостью слоёв
document.getElementById('chk-buildings').addEventListener('change', (e) => {
  buildingsLayer.setVisible(e.target.checked);
});
document.getElementById('chk-roads').addEventListener('change', (e) => {
  roadsLayer.setVisible(e.target.checked);
});
document.getElementById('chk-poi').addEventListener('change', (e) => {
  poiLayer.setVisible(e.target.checked);
});
document.getElementById('chk-overture').addEventListener('change', (e) => {
  overtureLayer.setVisible(e.target.checked);
});
