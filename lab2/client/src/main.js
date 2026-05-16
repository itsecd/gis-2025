import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';

console.log('OpenLayers карта с GeoServer слоями инициализируется...');

const baseLayer = new TileLayer({
  title: 'OSM',
  source: new OSM()
});

const buildingsLayer = new ImageLayer({
  title: 'Здания',
  visible: true,
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings',
      TILED: true,
      VERSION: '1.1.0',
      TRANSPARENT: true
    },
    serverType: 'geoserver',
    ratio: 1
  })
});

const roadsLayer = new ImageLayer({
  title: 'Дороги',
  visible: true,
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:roads',
      TILED: true,
      VERSION: '1.1.0',
      TRANSPARENT: true
    },
    serverType: 'geoserver',
    ratio: 1
  })
});

const map = new Map({
  target: 'map',
  layers: [baseLayer, buildingsLayer, roadsLayer],
  view: new View({
    center: fromLonLat([50.22, 53.29]),
    zoom: 15
  })
});

console.log('Карта с GeoServer слоями создана!');


document.getElementById('toggle-buildings').addEventListener('change', (e) => {
  buildingsLayer.setVisible(e.target.checked);
});

document.getElementById('toggle-roads').addEventListener('change', (e) => {
  roadsLayer.setVisible(e.target.checked);
});


map.on('click', (event) => {
  const coords = fromLonLat(event.coordinate);
  const infoDiv = document.querySelector('.coords-info');
  infoDiv.innerHTML = `Координаты (lon/lat): ${coords[0].toFixed(6)}, ${coords[1].toFixed(6)}`;
});

document.querySelector('.reset-view-btn').addEventListener('click', () => {
  map.getView().setCenter(fromLonLat([50.22, 53.29]));
  map.getView().setZoom(15);
});

console.log('Все слои добавлены, UI настроен');