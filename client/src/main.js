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
import { Style, Fill, Stroke } from "ol/style";

import { fromLonLat } from "ol/proj";

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

const COLOR = {
  my: { fill: "rgba(34, 197, 94, 0.6)", stroke: "#15803d" },
  osm: { fill: "rgba(59, 130, 246, 0.6)", stroke: "#1d4ed8" },
  ml: { fill: "rgba(249, 115, 22, 0.6)", stroke: "#c2410c" },
};

const overtureLayer = new VectorLayer({
  source: new VectorSource({
    url: "/overture.json",
    format: new GeoJSON(),
  }),
  style: (feature) => {
    const t = feature.get("source_type") || "ml";
    const c = COLOR[t] ?? COLOR.ml;
    return new Style({
      fill: new Fill({ color: c.fill }),
      stroke: new Stroke({ color: c.stroke, width: 1.5 }),
    });
  },
});

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
