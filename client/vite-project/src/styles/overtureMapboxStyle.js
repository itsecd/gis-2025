const overtureMapboxStyle = {
  version: 8,
  sources: {
    overture: {
      type: 'geojson',
      data: '/overture.geojson'
    }
  },
  layers: [
    {
      id: 'overture-my-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'my'],
      paint: {
        'fill-color': '#004025',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-osm-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'osm'],
      paint: {
        'fill-color': '#088da5',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-ml-fill',
      type: 'fill',
      source: 'overture',
      filter: ['==', 'source_type', 'ml'],
      paint: {
        'fill-color': '#d08615',
        'fill-opacity': 0.85
      }
    },
    {
      id: 'overture-outline',
      type: 'line',
      source: 'overture',
      paint: {
        'line-color': '#000000',
        'line-width': 2
      }
    }
  ]
};

export default overtureMapboxStyle;