import 'ol/ol.css'
import Map from 'ol/Map'
import View from 'ol/View'
import TileLayer from 'ol/layer/Tile'
import OSM from 'ol/source/OSM'
import ImageLayer from 'ol/layer/Image'
import ImageWMS from 'ol/source/ImageWMS'
import { fromLonLat } from 'ol/proj'
import VectorLayer from 'ol/layer/Vector'
import { applyStyle } from 'ol-mapbox-style'

const baseLayer = new TileLayer({
  source: new OSM()
})

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
})

const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:roads',
      TILED: true
    }
  })
})

const poiLayer = new ImageLayer({
  source: new ImageWMS({
    url: 'http://localhost:8080/geoserver/gis/wms',
    params: {
      LAYERS: 'gis:poi',
      TILED: true
    },
    projection: 'EPSG:3857',
    serverType: 'geoserver'
  })
})

const overtureLayer = new VectorLayer();

const map = new Map({
  target: 'map',
  layers: [
    baseLayer,
    buildingsLayer,
    roadsLayer,
    poiLayer,
    overtureLayer
  ],
  view: new View({
    center: fromLonLat([86.098705, 54.283765]),
    zoom: 16
  })
})
applyStyle(overtureLayer, '/style.json');