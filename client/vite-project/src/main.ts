import './style.css'
import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { stylefunction } from 'ol-mapbox-style';
import { mapboxStyle } from './mapbox-style';

const overtureSource = new VectorSource({
  url: '/overture.json',
  format: new GeoJSON(),
});

const overtureLayer = new VectorLayer({ source: overtureSource });

stylefunction(overtureLayer, mapboxStyle, 'overture');

new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    new ImageLayer({
      source: new ImageWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: { LAYERS: 'gis:buildings', TILED: true },
        ratio: 1,
        serverType: 'geoserver',
      }),
    }),
    new ImageLayer({
      source: new ImageWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: { LAYERS: 'gis:roads', TILED: true },
        ratio: 1,
        serverType: 'geoserver',
      }),
    }),
    new ImageLayer({
      source: new ImageWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: { LAYERS: 'gis:poi', TILED: true },
        ratio: 1,
        serverType: 'geoserver',
      }),
    }),
    overtureLayer,
  ],
  view: new View({
    center: fromLonLat([113.96, 62.535]),
    zoom: 14,
  }),
});
