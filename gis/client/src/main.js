import 'ol/ol.css';
import { Map, View } from 'ol';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import ImageLayer from 'ol/layer/Image';
import ImageWMS from 'ol/source/ImageWMS';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import { fromLonLat } from 'ol/proj';

const createWMSLayer = (layerName) => {
  return new ImageLayer({
    source: new ImageWMS({
      url: "http://localhost:8080/geoserver/gis/wms",
      params: {
        LAYERS: `gis:${layerName}`,
        TILED: true,
        TRANSPARENT: true,
        VERSION: "1.1.1"
      },
      ratio: 1,
      serverType: "geoserver",
    }),
  });
};

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new OSM()
    }),
    createWMSLayer('buildings'),
    createWMSLayer('roads'),
    createWMSLayer('poi')
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
      source: vectorSource,
      style: (feature) => {
        const sourceType = feature.get('source_type');
        let color = '#888888'; // прочие
        if (sourceType === 'my') color = '#4CAF50';      // зелёный
        if (sourceType === 'osm') color = '#2196F3';    // синий
        if (sourceType === 'ml') color = '#FF9800';     // оранжевый

        return {
          fill: new ol.style.Fill({ color }),
          stroke: new ol.style.Stroke({ color: '#000000', width: 1 })
        };
      }
    });

    map.addLayer(vectorLayer);

    const stats = { my: 0, osm: 0, ml: 0, other: 0 };
    geojsonData.features.forEach(f => {
      const source = f.properties?.source_type || 'other';
      stats[source]++;
    });
    addLegend(stats);
  })
  .catch(error => console.error('Ошибка загрузки GeoJSON:', error));

function addLegend(stats) {
  const legend = document.createElement('div');
  legend.className = 'legend';
  legend.innerHTML = `
    <h4>Overture Maps (ЛР3)</h4>
    <div><span style="background:#4CAF50"></span> Мои (my): ${stats.my}</div>
    <div><span style="background:#2196F3"></span> OSM (osm): ${stats.osm}</div>
    <div><span style="background:#FF9800"></span> ML (ml): ${stats.ml}</div>
    <div><span style="background:#888888"></span> Прочие: ${stats.other}</div>
    <hr>
    <div>Всего: ${stats.my + stats.osm + stats.ml + stats.other}</div>
  `;
  document.body.appendChild(legend);
}