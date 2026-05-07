#!/bin/sh
set -e

GS_URL="http://geoserver:8080/geoserver"
GS_USER="admin"
GS_PASS="geoserver"

echo "==> Creating workspace 'gis'..."
curl -sf -u "$GS_USER:$GS_PASS" -X POST "$GS_URL/rest/workspaces" \
  -H "Content-Type: application/json" \
  -d '{"workspace": {"name": "gis"}}' || true

echo "==> Creating datastore 'postgis_db'..."
curl -sf -u "$GS_USER:$GS_PASS" -X POST "$GS_URL/rest/workspaces/gis/datastores" \
  -H "Content-Type: application/json" \
  -d '{
    "dataStore": {
      "name": "postgis_db",
      "connectionParameters": {
        "entry": [
          {"@key": "dbtype",   "$": "postgis"},
          {"@key": "host",     "$": "postgis"},
          {"@key": "port",     "$": "5432"},
          {"@key": "database", "$": "gis"},
          {"@key": "schema",   "$": "public"},
          {"@key": "user",     "$": "gisuser"},
          {"@key": "passwd",   "$": "gispass"}
        ]
      }
    }
  }' || true

echo "==> Publishing layer 'buildings'..."
curl -sf -u "$GS_USER:$GS_PASS" -X POST \
  "$GS_URL/rest/workspaces/gis/datastores/postgis_db/featuretypes" \
  -H "Content-Type: application/json" \
  -d '{
    "featureType": {
      "name": "buildings",
      "nativeName": "buildings",
      "srs": "EPSG:4326",
      "nativeCRS": "EPSG:4326"
    }
  }' || true

echo "==> Publishing layer 'roads'..."
curl -sf -u "$GS_USER:$GS_PASS" -X POST \
  "$GS_URL/rest/workspaces/gis/datastores/postgis_db/featuretypes" \
  -H "Content-Type: application/json" \
  -d '{
    "featureType": {
      "name": "roads",
      "nativeName": "roads",
      "srs": "EPSG:4326",
      "nativeCRS": "EPSG:4326"
    }
  }' || true

echo "==> Publishing layer 'poi'..."
curl -sf -u "$GS_USER:$GS_PASS" -X POST \
  "$GS_URL/rest/workspaces/gis/datastores/postgis_db/featuretypes" \
  -H "Content-Type: application/json" \
  -d '{
    "featureType": {
      "name": "poi",
      "nativeName": "poi",
      "srs": "EPSG:4326",
      "nativeCRS": "EPSG:4326"
    }
  }' || true

echo "==> GeoServer initialization complete."
