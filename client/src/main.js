import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import VectorLayer from 'ol/layer/Vector';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { stylefunction } from 'ol-mapbox-style';
import overtureStyle from './overture-style.json';
import './style.css';

const geoserverWmsUrl = 'http://localhost:8080/geoserver/gis/wms';

const createWmsLayer = (layerName) =>
  new ImageLayer({
    source: new ImageWMS({
      url: geoserverWmsUrl,
      params: {
        LAYERS: layerName,
        TILED: true,
        FORMAT: 'image/png',
        TRANSPARENT: true,
      },
      ratio: 1,
      serverType: 'geoserver',
    }),
    opacity: 0.75,
  });

const overtureLayer = new VectorLayer({
  source: new VectorSource({
    url: '/data/overture.geojson',
    format: new GeoJSON(),
  }),
});

stylefunction(overtureLayer, overtureStyle, 'overture');

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM(),
    }),
    createWmsLayer('gis:buildings'),
    createWmsLayer('gis:roads'),
    createWmsLayer('gis:poi'),
    overtureLayer,
  ],
  view: new View({
    center: fromLonLat([50.1287, 53.524]),
    zoom: 16,
  }),
});

window.map = map;
