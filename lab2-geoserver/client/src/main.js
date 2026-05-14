import './style.css';
import 'ol/ol.css';

import Map from 'ol/Map.js';
import View from 'ol/View.js';
import TileLayer from 'ol/layer/Tile.js';
import OSM from 'ol/source/OSM.js';
import { fromLonLat } from 'ol/proj.js';

import apply from 'ol-mapbox-style';
import overtureStyle from './overture-style.json';

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM()
    })
  ],
  view: new View({
    center: fromLonLat([106.780, 11.040]),
    zoom: 18
  })
});

apply(map, overtureStyle).then(() => {
  console.log('Overture GeoJSON style applied successfully');
});