import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import VectorLayer from 'ol/layer/Vector';
import OSM from 'ol/source/OSM';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { stylefunction } from 'ol-mapbox-style';
import './style.css';

const overtureLayer = new VectorLayer({
  source: new VectorSource({
    url: '/data/overture.geojson',
    format: new GeoJSON(),
  }),
});

const overtureStyle = {
  version: 8,
  sources: {
    overture: {
      type: 'geojson',
      data: '/data/overture.geojson',
    },
  },
  layers: [
    {
      id: 'overture-buildings',
      type: 'fill',
      source: 'overture',
      paint: {
        'fill-color': [
          'match',
          ['get', 'source_type'],
          'my',
          '#2ca25f',
          'osm',
          '#2b8cbe',
          'ml',
          '#f28e2b',
          '#8f9aa7',
        ],
        'fill-opacity': 0.72,
      },
    },
    {
      id: 'overture-building-outlines',
      type: 'line',
      source: 'overture',
      paint: {
        'line-color': '#1f2937',
        'line-opacity': 0.7,
        'line-width': [
          'interpolate',
          ['linear'],
          ['zoom'],
          15,
          0.6,
          18,
          1.4,
        ],
      },
    },
  ],
};

stylefunction(overtureLayer, overtureStyle, 'overture');

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM(),
    }),
    overtureLayer,
  ],
  view: new View({
    center: fromLonLat([50.1287, 53.524]),
    zoom: 16,
  }),
});

window.map = map;
