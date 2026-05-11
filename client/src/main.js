import 'ol/ol.css';
import './style.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';

const geoserverUrl = 'http://localhost:8080/geoserver/gis/wms';

function createWmsLayer(layerName) {
  return new ImageLayer({
    source: new ImageWMS({
      url: geoserverUrl,
      params: {
        LAYERS: `gis:${layerName}`,
        TILED: true,
      },
      ratio: 1,
      serverType: 'geoserver',
    }),
  });
}

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    createWmsLayer('buildings'),
    createWmsLayer('roads'),
    createWmsLayer('poi'),
  ],
  view: new View({
    // Замени координаты на центр своего участка: fromLonLat([долгота, широта])
    center: fromLonLat([49.2315, 53.5960]),
    zoom: 15,
  }),
});

window.map = map;
