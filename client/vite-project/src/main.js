import 'ol/ol.css';

import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { stylefunction } from 'ol-mapbox-style';

const vectorSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON()
});

const vectorLayer = new VectorLayer({
  source: vectorSource
});

fetch('/style.json')
  .then(r => r.json())
  .then(style => {
    stylefunction(vectorLayer, style, 'overture');
  });

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    vectorLayer
  ],
  view: new View({
    center: [0, 0],
    zoom: 2
  })
});

vectorSource.once('change', () => {
  if (vectorSource.getState() === 'ready') {
    map.getView().fit(vectorSource.getExtent(), { padding: [50, 50, 50, 50] });
  }
});
