import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';


// Базовая подложка OpenStreetMap
const osmLayer = new TileLayer({
  source: new OSM()
});


// Cлой зданий
const buildingsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:buildings',
      TILED: true
    },
    ratio: 1,
    serverType: 'geoserver'
  })
});


// Cлой дорог
const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:roads',
      TILED: true
    },
    ratio: 1,
    serverType: 'geoserver'
  })
});


// Cлой POI
const poiLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:poi',
      TILED: true
    },
    ratio: 1,
    serverType: 'geoserver'
  })
});


// Создание карты
const map = new Map({
  target: 'map',
  layers: [
    osmLayer,
    buildingsLayer,
    roadsLayer,
    poiLayer
  ],
  view: new View({

    // Центр карты
    center: fromLonLat([50.5994, 53.2113]),

    // Масштаб
    zoom: 17
  })
});