import './style.css';
import 'ol/ol.css';

import Map from 'ol/Map';
import View from 'ol/View';

import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';

import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';

import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';

import {applyStyle} from 'ol-mapbox-style';
import {useGeographic} from 'ol/proj';

useGeographic(); 


const baseLayer = new TileLayer({
  source: new OSM()
});


const buildingsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings'
    },
    ratio: 1,
    serverType: 'geoserver'
  })
});


const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:roads'
    },
    ratio: 1,
    serverType: 'geoserver'
  })
});


const poiLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:poi'
    },
    ratio: 1,
    serverType: 'geoserver'
  })
});

const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON()
});

const overtureLayer = new VectorLayer({
  source: overtureSource
});

const map = new Map({
  target: 'map',
  layers: [
    baseLayer,
    buildingsLayer,
    roadsLayer,
    poiLayer,
    overtureLayer   
  ],
  view: new View({
    center: [49.2191, 53.5979], 
    zoom: 17
  })
});

applyStyle(overtureLayer, '/overture-style.json', 'overture');