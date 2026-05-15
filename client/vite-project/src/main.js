import { fromLonLat } from 'ol/proj';
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

import { stylefunction } from 'ol-mapbox-style';

const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON()
});

const overtureLayer = new VectorLayer({
  source: overtureSource
});

fetch('/style.json')
  .then((r) => r.json())
  .then((style) => {
    stylefunction(overtureLayer, style, 'overture');
  });

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM()
    }),

    new ImageLayer({
      source: new ImageWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: {
          LAYERS: 'gis:buildings',
          TILED: true,
          TRANSPARENT: true
        },
        serverType: 'geoserver'
      })
    }),

    new ImageLayer({
      source: new ImageWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: {
          LAYERS: 'gis:roads',
          TILED: true,
          TRANSPARENT: true
        },
        serverType: 'geoserver'
      })
    }),

    new ImageLayer({
      source: new ImageWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: {
          LAYERS: 'gis:pois',
          TILED: true,
          TRANSPARENT: true
        },
        serverType: 'geoserver'
      })
    }),

    overtureLayer
  ],
  view: new View({
    center: fromLonLat([50.45, 53.23]),
    zoom: 14
  })
});

overtureSource.once('change', () => {
  if (overtureSource.getState() === 'ready') {
    map.getView().fit(overtureSource.getExtent(), {
      padding: [50, 50, 50, 50]
    });
  }
});
