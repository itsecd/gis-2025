import './style.css'
import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import OSM from 'ol/source/OSM';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { stylefunction } from 'ol-mapbox-style';

const mapboxStyle = {
  version: 8,
  sources: {
    overture: {
      type: 'geojson',
      data: '/overture.json',
    },
  },
  layers: [
    {
      id: 'buildings-my',
      type: 'fill',
      source: 'overture',
      filter: ['==', ['get', 'source_type'], 'my'],
      paint: {
        'fill-color': '#22c55e',
        'fill-opacity': 0.6,
        'fill-outline-color': '#16a34a',
      },
    },
    {
      id: 'buildings-osm',
      type: 'fill',
      source: 'overture',
      filter: ['==', ['get', 'source_type'], 'osm'],
      paint: {
        'fill-color': '#3b82f6',
        'fill-opacity': 0.6,
        'fill-outline-color': '#2563eb',
      },
    },
    {
      id: 'buildings-ml',
      type: 'fill',
      source: 'overture',
      filter: ['==', ['get', 'source_type'], 'ml'],
      paint: {
        'fill-color': '#f97316',
        'fill-opacity': 0.6,
        'fill-outline-color': '#ea580c',
      },
    },
  ],
};

const overtureSource = new VectorSource({
  url: '/overture.json',
  format: new GeoJSON(),
});

const overtureLayer = new VectorLayer({ source: overtureSource });

stylefunction(overtureLayer, mapboxStyle, 'overture');

new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    overtureLayer,
  ],
  view: new View({
    center: fromLonLat([113.96, 62.535]),
    zoom: 14,
  }),
});
