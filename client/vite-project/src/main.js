import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import TileWMS from 'ol/source/TileWMS';
import ImageLayer from 'ol/layer/Image';
import { apply } from 'ol-mapbox-style';

const styleUrl = '/style.json';

const map = new Map({ target: 'map' });

apply(map, styleUrl)
  .then(() => {
    map.getLayers().insertAt(1, new TileLayer({
      source: new TileWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: {
          LAYERS: 'gis:buildings',
          TILED: true,
          FORMAT: 'image/png',
          TRANSPARENT: true
        },
        projection: 'EPSG:4326',
        serverType: 'geoserver'
      }),
    }));

    map.getLayers().insertAt(1, new TileLayer({
      source: new TileWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: {
          LAYERS: 'gis:roads',
          TILED: true,
          FORMAT: 'image/png',
          TRANSPARENT: true
        },
        projection: 'EPSG:4326',
        serverType: 'geoserver'
      })
    }));

    map.getLayers().insertAt(1, new TileLayer({
      source: new TileWMS({
        url: 'http://localhost:8080/geoserver/gis/wms',
        params: {
          LAYERS: 'gis:poi',
          TILED: true,
          FORMAT: 'image/png',
          TRANSPARENT: true
        },
        projection: 'EPSG:4326',
        serverType: 'geoserver'
      })
    }));

    map.setView(new View({
      projection: 'EPSG:4326',
      center: [49.839259, 53.472939],
      zoom: 19
    }));
  });