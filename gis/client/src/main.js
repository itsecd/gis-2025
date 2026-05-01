import 'ol/ol.css';
import { Map, View } from 'ol';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';
import { applyStyle } from 'ol-mapbox-style';

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM()
    })
  ],
  view: new View({
    center: fromLonLat([50.2467455, 53.4376983]),
    zoom: 17
  })
});

fetch('/overture_map.geojson')
  .then(response => response.json())
  .then(data => {
    let geojsonData = data;
    if (data.geojson) geojsonData = data.geojson;
    
    const vectorSource = new VectorSource({
      features: new GeoJSON().readFeatures(geojsonData, {
        dataProjection: 'EPSG:4326',
        featureProjection: 'EPSG:3857'
      })
    });

    const vectorLayer = new VectorLayer({
      source: vectorSource
    });

    applyStyle(vectorLayer, '/mapbox-style.json');
    map.addLayer(vectorLayer);
    
    const stats = { my: 0, osm: 0, ml: 0, other: 0 };
    geojsonData.features.forEach(f => {
      const source = f.properties?.source_type || 'other';
      stats[source]++;
    });
    addLegend(stats);
  });

function addLegend(stats) {
  const legend = document.createElement('div');
  legend.className = 'legend';
  legend.innerHTML = `
    <h4>Overture Maps</h4>
    <div><span style="background:#2ecc71"></span> Мои (my): ${stats.my}</div>
    <div><span style="background:#3498db"></span> OSM (osm): ${stats.osm}</div>
    <div><span style="background:#e67e22"></span> ML (ml): ${stats.ml}</div>
    <div><span style="background:#888888"></span> Прочие: ${stats.other}</div>
    <hr><div>Всего: ${stats.my + stats.osm + stats.ml + stats.other}</div>
  `;
  document.body.appendChild(legend);
}