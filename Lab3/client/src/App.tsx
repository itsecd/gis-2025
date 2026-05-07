import { useEffect, useRef } from 'react'

import GeoJSON from 'ol/format/GeoJSON'
import { Map, View } from 'ol'
import TileLayer from 'ol/layer/Tile'
import ImageLayer from 'ol/layer/Image'
import VectorLayer from 'ol/layer/Vector'
import { OSM, Vector as VectorSource } from 'ol/source'
import { applyStyle } from 'ol-mapbox-style'
import MAPBOX_CHOROPLETH_STYLE from './assets/style_conf.json'
import ImageWMS from 'ol/source/ImageWMS'

const MAP_CENTER: [number, number] = [5625071.318498041, 7028775.190074967]
const MAP_ZOOM = 16

function createWmsLayer(layerName: string) {
  return new ImageLayer({
    source: new ImageWMS({
      url: 'http://localhost:8080/geoserver/gis/wms',
      params: {
        LAYERS: layerName,
        TILED: true,
      },
      ratio: 1,
      serverType: 'geoserver',
    }),
  })
}

function App() {
  const mapContainerRef = useRef<HTMLDivElement | null>(null)
  const mapRef = useRef<Map | null>(null)

  useEffect(() => {
    if (!mapContainerRef.current || mapRef.current) return

    const overtureSource = new VectorSource({
      url: '/overture.geojson',
      format: new GeoJSON(),
    })

    const overtureLayer = new VectorLayer({
      source: overtureSource,
    })

    void applyStyle(overtureLayer, MAPBOX_CHOROPLETH_STYLE, {
      source: 'overture',
      updateSource: false,
    })

    const map = new Map({
      target: mapContainerRef.current,
      layers: [
        new TileLayer({ source: new OSM() }),
        createWmsLayer('gis:buildings'),
        createWmsLayer('gis:roads'),
        overtureLayer,
      ],
      view: new View({
        center: MAP_CENTER,
        zoom: MAP_ZOOM,
      }),
    })

    overtureSource.once('featuresloadend', () => {
      const extent = overtureSource.getExtent()
      if (extent && Number.isFinite(extent[0])) {
        map.getView().fit(extent, { duration: 600, padding: [24, 24, 24, 24] })
      }
    })

    mapRef.current = map

    return () => {
      map.setTarget(undefined)
      mapRef.current = null
    }
  }, [])

  return <div ref={mapContainerRef} className="map-canvas" />
}

export default App
