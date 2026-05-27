import './style.css';
import 'ol/ol.css';

import Map from 'ol/Map';
import View from 'ol/View';

import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';

import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';

import { fromLonLat } from 'ol/proj';

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

const map = new Map({
  target: 'map',

  layers: [
    new TileLayer({
      source: new OSM()
    }),

    buildingsLayer,
    roadsLayer,
    poiLayer
  ],

  view: new View({
    center: fromLonLat([49.28920, 53.59286]),
    zoom: 17
  })
});