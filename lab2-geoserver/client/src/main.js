import 'ol/ol.css';
import './style.css';

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
import { applyStyle } from 'ol-mapbox-style';
import overtureStyle from './overture-style.json';

const GEOSERVER_WMS_URL = 'http://localhost:8080/geoserver/gis/wms';
const MAP_CENTER = [106.77738, 11.04008];
const MAP_ZOOM = 18;

const osmLayer = new TileLayer({
  source: new OSM(),
  visible: true
});
osmLayer.set('title', 'OSM base map');
osmLayer.setZIndex(0);

function createWmsLayer(layerName, { opacity = 1, visible = false, zIndex = 10 } = {}) {
  const layer = new ImageLayer({
    source: new ImageWMS({
      url: GEOSERVER_WMS_URL,
      params: {
        LAYERS: layerName,
        TILED: true,
        FORMAT: 'image/png',
        TRANSPARENT: true
      },
      ratio: 1,
      serverType: 'geoserver',
      crossOrigin: 'anonymous'
    }),
    opacity,
    visible
  });

  layer.set('title', `GeoServer: ${layerName}`);
  layer.setZIndex(zIndex);
  return layer;
}

const geoserverLayers = [
  createWmsLayer('gis:buildings', { opacity: 0.9, zIndex: 20 }),
  createWmsLayer('gis:other_objects', { opacity: 0.9, zIndex: 21 }),
  createWmsLayer('gis:roads', { opacity: 1, zIndex: 22 }),
  createWmsLayer('gis:poi', { opacity: 1, zIndex: 23 })
];

const overtureLayer = new VectorLayer({
  source: new VectorSource({
    url: '/data/overture.geojson',
    format: new GeoJSON()
  }),
  opacity: 0.75,
  visible: true
});
overtureLayer.set('title', 'Overture: source_type');
overtureLayer.setZIndex(5);

const layers = [osmLayer, overtureLayer, ...geoserverLayers];

const map = new Map({
  target: 'map',
  layers,
  view: new View({
    center: fromLonLat(MAP_CENTER),
    zoom: MAP_ZOOM
  })
});

applyStyle(overtureLayer, overtureStyle, 'overture-buildings')
  .then(() => console.log('Overture GeoJSON style applied'))
  .catch((error) => console.error('Failed to apply Overture style:', error));

function createLayerControl(layersForControl) {
  const container = document.getElementById('layer-control');
  if (!container) return;

  layersForControl.forEach((layer) => {
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.checked = layer.getVisible();

    checkbox.addEventListener('change', () => {
      layer.setVisible(checkbox.checked);

      const source = layer.getSource();
      if (checkbox.checked && source instanceof ImageWMS) {
        source.updateParams({ _t: Date.now() });
      }
    });

    const label = document.createElement('label');
    label.className = 'layer-control-item';
    label.append(checkbox, ` ${layer.get('title')}`);

    container.appendChild(label);
  });
}

createLayerControl(layers);



