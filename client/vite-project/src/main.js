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
import { Style, Fill, Stroke } from 'ol/style';

function overtureStyleFunction(feature) {
  const colorMap = {
    my:  '#00ff00',
    osm: '#0000ff',
    ml:  '#ffa500',
    other: '#cccccc'
  };

  const sourceType = feature.get('source_type') || 'other';
  const color = colorMap[sourceType] || colorMap.other;

  return new Style({
    fill: new Fill({ color: color + '80' }),
    stroke: new Stroke({ color: color, width: 1 })
  });
}

const overtureSource = new VectorSource({
  url: '/overture.geojson',
  format: new GeoJSON()
});

const overtureLayer = new VectorLayer({
  source: overtureSource,
  style: overtureStyleFunction
});

const buildingsWMS = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: { LAYERS: 'gis:buildings', TILED: true },
    ratio: 1,
    serverType: 'geoserver'
  })
});

const roadsWMS = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: { LAYERS: 'gis:roads', TILED: true },
    ratio: 1,
    serverType: 'geoserver'
  })
});

const poiWMS = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: { LAYERS: 'gis:poi', TILED: true },
    ratio: 1,
    serverType: 'geoserver'
  })
});

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({ source: new OSM() }),
    buildingsWMS,
    roadsWMS,
    poiWMS,
    overtureLayer
  ],
  view: new View({
    projection: 'EPSG:4326',
    center: [49.839259, 53.472939],
    zoom: 19
  })
});