import 'ol/ol.css';
import './style.css';
import OlMap from 'ol/Map';
import View from 'ol/View';
import ImageLayer from 'ol/layer/Image';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import {fromLonLat} from 'ol/proj';

const geoserverWmsUrl = 'http://localhost:8080/geoserver/gis/wms';

function createWmsLayer(layerName) {
  return new ImageLayer({
    source: new ImageWMS({
      url: geoserverWmsUrl,
      params: {
        LAYERS: `gis:${layerName}`,
        VERSION: '1.1.0',
        FORMAT: 'image/png',
        TRANSPARENT: true
      },
      ratio: 1,
      serverType: 'geoserver',
      crossOrigin: 'anonymous'
    }),
    opacity: 0.78,
    visible: layerName === 'buildings'
  });
}

const buildingsLayer = createWmsLayer('buildings');
const roadsLayer = createWmsLayer('roads');
const poisLayer = createWmsLayer('pois');

const map = new OlMap({
  target: 'map',
  layers: [
    new TileLayer({source: new OSM()}),
    buildingsLayer,
    roadsLayer,
    poisLayer
  ],
  view: new View({
    center: fromLonLat([50.65868, 53.28212]),
    zoom: 18
  })
});

const toggles = new globalThis.Map([
  ['buildings-toggle', buildingsLayer],
  ['roads-toggle', roadsLayer],
  ['pois-toggle', poisLayer]
]);

for (const [id, layer] of toggles) {
  const control = document.getElementById(id);
  control.checked = layer.getVisible();
  control.addEventListener('change', (event) => {
    layer.setVisible(event.target.checked);
  });
}
