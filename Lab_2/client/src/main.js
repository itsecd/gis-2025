import 'ol/ol.css';
import './style.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { Style, Fill, Stroke } from 'ol/style';

const osmLayer = new TileLayer({
  source: new OSM(),
  visible: true,
  zIndex: 0
});

const buildingsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings',
      TILED: true,
      FORMAT: 'image/png',
      TRANSPARENT: true
    },
    ratio: 1,
    serverType: 'geoserver'
  }),
  visible: true,
  zIndex: 1
});

const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:roads',
      TILED: true,
      FORMAT: 'image/png',
      TRANSPARENT: true
    },
    ratio: 1,
    serverType: 'geoserver'
  }),
  visible: true,
  zIndex: 2
});

const poiLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:poi',
      TILED: true,
      FORMAT: 'image/png',
      TRANSPARENT: true
    },
    ratio: 1,
    serverType: 'geoserver'
  }),
  visible: false,
  zIndex: 3
});

const overtureLayer = new VectorLayer({
  source: new VectorSource({
    url: 'overture.geojson',
    format: new GeoJSON()
  }),
  visible: true,
  zIndex: 4,
  style: function(feature) {
    const sourceType = feature.get('source_type');
    let color;
    switch(sourceType) {
      case 'my': color = '#2ecc71'; break;
      case 'osm': color = '#3498db'; break;
      case 'ml': color = '#e67e22'; break;
      default: color = '#95a5a6'; break;
    }
    return new Style({
      fill: new Fill({ color: color + '80' }),
      stroke: new Stroke({ color: color, width: 1 })
    });
  }
});

const layers = {
  osm: osmLayer,
  roads: roadsLayer,
  buildings: buildingsLayer,
  poi: poiLayer,
  overture: overtureLayer
};

const center = fromLonLat([106.38, 52.79]);

const map = new Map({
  target: 'map',
  layers: [osmLayer, buildingsLayer, roadsLayer, poiLayer, overtureLayer],
  view: new View({
    center: center,
    zoom: 14,
    maxZoom: 19,
    minZoom: 10
  })
});

document.addEventListener('DOMContentLoaded', () => {
  const toggles = ['osm', 'roads', 'buildings', 'poi'];
  
  toggles.forEach(layerName => {
    const toggle = document.getElementById(`toggle-${layerName}`);
    if (toggle) {
      toggle.checked = layers[layerName].getVisible();
      toggle.addEventListener('change', (e) => {
        switch(layerName) {
          case 'osm':
            layers.osm.setVisible(e.target.checked);
            break;
          case 'roads':
            layers.roads.setVisible(e.target.checked);
            break;
          case 'buildings':
            layers.buildings.setVisible(e.target.checked);
            break;
          case 'poi':
            layers.poi.setVisible(e.target.checked);
            break;
          default:
            console.log(`Неизвестный слой: ${layerName}`);
        }
      });
    }
  });
  
  const layerList = document.querySelector('.layer-list');
  if (layerList && !document.getElementById('toggle-overture')) {
    const overtureItem = document.createElement('label');
    overtureItem.className = 'layer-item';
    overtureItem.innerHTML = `
      <input type="checkbox" id="toggle-overture" checked />
      <span class="layer-name">
        <span class="color-dot" style="background: #2ecc71; box-shadow: 0 2px 4px rgba(46, 204, 113, 0.3);"></span>
        Overture Buildings
      </span>
      <span class="layer-badge">источники</span>
    `;
    layerList.appendChild(overtureItem);
    
    const toggleOverture = document.getElementById('toggle-overture');
    if (toggleOverture) {
      toggleOverture.addEventListener('change', (e) => {
        overtureLayer.setVisible(e.target.checked);
      });
    }
  }
});