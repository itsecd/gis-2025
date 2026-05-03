import "./style.css";
import "ol/ol.css";
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import ImageLayer from "ol/layer/Image";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import OSM from "ol/source/OSM";
import ImageWMS from "ol/source/ImageWMS";
import GeoJSON from "ol/format/GeoJSON";
import { fromLonLat } from "ol/proj";
import { stylefunction } from "ol-mapbox-style";

const geoserverWmsUrl = "http://localhost:8080/geoserver/gis/wms";

const buildingsLayer = new ImageLayer({
  source: new ImageWMS({
    url: geoserverWmsUrl,
    params: { LAYERS: "gis:buildings", TILED: true },
    ratio: 1,
    serverType: "geoserver",
  }),
  opacity: 0.7,
});

const roadsLayer = new ImageLayer({
  source: new ImageWMS({
    url: geoserverWmsUrl,
    params: { LAYERS: "gis:roads", TILED: true },
    ratio: 1,
    serverType: "geoserver",
  }),
});

const poiLayer = new ImageLayer({
  source: new ImageWMS({
    url: geoserverWmsUrl,
    params: { LAYERS: "gis:poi", TILED: true },
    ratio: 1,
    serverType: "geoserver",
  }),
});

const overtureSource = new VectorSource({
  url: "/overture.json",
  format: new GeoJSON(),
});

const overtureLayer = new VectorLayer({
  source: overtureSource,
});

const mapboxStyle = await fetch("/style.json").then((r) => r.json());
stylefunction(overtureLayer, mapboxStyle, "overture");

new Map({
  target: "map",
  layers: [
    new TileLayer({ source: new OSM() }),
    buildingsLayer,
    roadsLayer,
    poiLayer,
    overtureLayer,
  ],
  view: new View({
    center: fromLonLat([49.29638160000001, 53.5922908]),
    zoom: 16,
  }),
});
