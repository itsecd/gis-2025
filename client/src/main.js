import 'ol/ol.css';
import './style.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';

const geoserverWmsUrl = 'http://localhost:8081/geoserver/gis/wms';

const createWmsLayer = (layerName) => new ImageLayer({
  source: new ImageWMS({
    url: geoserverWmsUrl,
    params: {
      LAYERS: layerName,
      TILED: true,
      TRANSPARENT: true,
    },
    ratio: 1,
    serverType: 'geoserver',
  }),
});

const osmLayer = new TileLayer({
  source: new OSM(),
});

const buildingsLayer = createWmsLayer('gis:buildings');
const roadsLayer = createWmsLayer('gis:roads');
const poiLayer = createWmsLayer('gis:poi');

const map = new Map({
  target: 'map',
  layers: [osmLayer, buildingsLayer, roadsLayer, poiLayer],
  view: new View({
    center: fromLonLat([49.9746, 53.1284]),
    zoom: 17,
  }),
});
