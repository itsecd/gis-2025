import "ol/ol.css";

import Map from "ol/Map";
import View from "ol/View";

import TileLayer from "ol/layer/Tile";
import OSM from "ol/source/OSM";

import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import GeoJSON from "ol/format/GeoJSON";

import { fromLonLat } from "ol/proj";

import { applyStyle } from "ol-mapbox-style";

const map = new Map({
  target: "map",
  layers: [
    new TileLayer({
      source: new OSM(),
    }),
  ],
  view: new View({
    center: fromLonLat([50.412987, 53.118023]),
    zoom: 16,
  }),
});

const overtureLayer = new VectorLayer({
  source: new VectorSource({
    url: "overture.geojson",
    format: new GeoJSON(),
  }),
});

applyStyle(overtureLayer, {
  version: 8,
  sources: {
    overture: {
      type: "geojson",
      data: "overture.geojson",
    },
  },
  layers: [
    {
      id: "my",
      type: "fill",
      source: "overture",
      filter: ["==", ["get", "source_type"], "my"],
      paint: {
        "fill-color": "green",
        "fill-opacity": 0.5,
      },
    },
    {
      id: "osm",
      type: "fill",
      source: "overture",
      filter: ["==", ["get", "source_type"], "osm"],
      paint: {
        "fill-color": "blue",
        "fill-opacity": 0.5,
      },
    },
    {
      id: "ml",
      type: "fill",
      source: "overture",
      filter: ["==", ["get", "source_type"], "ml"],
      paint: {
        "fill-color": "orange",
        "fill-opacity": 0.5,
      },
    },
  ],
});


map.addLayer(overtureLayer);