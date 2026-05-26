import 'ol/ol.css';
import './style.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM(),
    }),
  ],
  view: new View({
    center: fromLonLat([49.9746, 53.1284]),
    zoom: 17,
  }),
});

const wmsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8081/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings',
      TILED: true,
    },
    ratio: 1,
    serverType: 'geoserver',
  }),
});

map.addLayer(wmsLayer);
