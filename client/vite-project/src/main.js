import { fromLonLat } from 'ol/proj';
import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';
import './style.css';

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM()
    })
  ],
  view: new View({
    center: fromLonLat([37.6, 55.7]),
    zoom: 12
  })
});

// Слой зданий
const buildingsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: { LAYERS: 'gis:buildings', TILED: true },
    serverType: 'geoserver'
  })
});
map.addLayer(buildingsLayer);

// Слой дорог
const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: { LAYERS: 'gis:roads', TILED: true },
    serverType: 'geoserver'
  })
});
map.addLayer(roadsLayer);

// Слой POI
const poisLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: { LAYERS: 'gis:pois', TILED: true },
    serverType: 'geoserver'
  })
});
map.addLayer(poisLayer);
