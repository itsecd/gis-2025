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


const overtureMapboxStyle = {
  version: 8,
  sources: {
    overture: {
      type: 'geojson',
      data: '/overture.geojson'
    }
  },
  layers: [
    {
      id: 'overture-my-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'my'],
      paint: {
        'fill-color': '#004025',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-osm-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'osm'],
      paint: {
        'fill-color': '#088da5',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-ml-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'ml'],
      paint: {
        'fill-color': '#d08615',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-outline',
      type: 'line',
      source: 'overture',
      paint: {
        'line-color': '#000000',
        'line-width': 2
      }
    }
  ]
};

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