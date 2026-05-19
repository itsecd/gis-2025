import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';

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
const roadsLayer = makeWmsLayer('gis:roads');
const poiLayer = makeWmsLayer('gis:poi');

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    buildingsLayer,
    roadsLayer,
    poiLayer,
  ],
  view: new View({
    center: fromLonLat([50.196, 53.221]),
    zoom: 15,
  }),
});

document.getElementById('chk-buildings').addEventListener('change', (e) => {
  buildingsLayer.setVisible(e.target.checked);
});
document.getElementById('chk-roads').addEventListener('change', (e) => {
  roadsLayer.setVisible(e.target.checked);
});
document.getElementById('chk-poi').addEventListener('change', (e) => {
  poiLayer.setVisible(e.target.checked);
});
