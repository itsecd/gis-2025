import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import ImageLayer from 'ol/layer/Image';
import OSM from 'ol/source/OSM';
import ImageWMS from 'ol/source/ImageWMS';
import { fromLonLat } from 'ol/proj';

const wms = (layer) => new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: { LAYERS: layer, TILED: true },
    serverType: 'geoserver',
  }),
});

new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    wms('gis:buildings'),
    wms('gis:roads'),
    wms('gis:poi'),
  ],
  view: new View({
    center: fromLonLat([49.2315, 53.5960]),
    zoom: 15,
  }),
});
