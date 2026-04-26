import 'ol/ol.css';
import './style.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import VectorLayer from 'ol/layer/Vector';
import OSM from 'ol/source/OSM';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { applyStyle } from 'ol-mapbox-style';
import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';

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
        'fill-color': '#4caf50',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-osm-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'osm'],
      paint: {
        'fill-color': '#2196f3',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-ml-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'ml'],
      paint: {
        'fill-color': '#ff9800',
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

const osmLayer = new TileLayer({
  source: new OSM()
});

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
    osmLayer,
    buildingsLayer,
    roadsLayer,
    overtureLayer
  ],
  view: new View({
    center: [0, 0],
    zoom: 2
  })
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