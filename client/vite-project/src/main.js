import 'ol/ol.css';

import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { applyStyle } from 'ol-mapbox-style';
import ImageLayer from 'ol/layer/Image';
import { fromLonLat } from 'ol/proj';

import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';

import overtureMapboxStyle from './styles/overtureMapboxStyle';

document.body.style.margin = '0';

const mapElement = document.getElementById('map');
mapElement.style.width = '100vw';
mapElement.style.height = '100vh';

const buildingsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings',
      FORMAT: 'image/png',
      TRANSPARENT: true,
    },
    ratio: 1,
    serverType: 'geoserver',
  }),
});

const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:roads',
      FORMAT: 'image/png',
      TRANSPARENT: true,
    },
    ratio: 1,
    serverType: 'geoserver',
  }),
});

const poiLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:poi',
      FORMAT: 'image/png',
      TRANSPARENT: true,
    },
    ratio: 1,
    serverType: 'geoserver',
  }),
});

const overtureSource = new VectorSource();

const overtureLayer = new VectorLayer({
  source: overtureSource,
  zIndex: 1000
});

applyStyle(overtureLayer, overtureMapboxStyle, 'overture', {
  updateSource: false
});

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    roadsLayer,
    buildingsLayer,
    poiLayer,
    overtureLayer
  ],
  view: new View({
    center: fromLonLat([-1.5458234, 51.9376323]), // -1.5458234 | 51.9376323
    zoom: 17,
  }),
});

fetch('/overture.geojson')
  .then(response => {
    return response.json();
  })
  .then(data => {
    const features = new GeoJSON().readFeatures(data, {
      dataProjection: 'EPSG:4326',
      featureProjection: 'EPSG:3857'
    });

    overtureSource.clear();
    overtureSource.addFeatures(features);

    map.getView().fit(overtureSource.getExtent(), {
      padding: [50, 50, 50, 50],
      maxZoom: 19,
      duration: 500
    });
  })
  .catch(error => {
    console.error('GeoJSON error:', error);
  });