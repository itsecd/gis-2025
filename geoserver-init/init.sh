#!/bin/sh
set -eu

GS_URL="http://geoserver:8080/geoserver"
AUTH="admin:geoserver"
WORKSPACE="gis"
STORE="postgis"
NAMESPACE="https://ssau.ru/gis"

wait_for_geoserver() {
  until curl -sf -u "$AUTH" "$GS_URL/rest/about/version.xml" >/dev/null; do
    echo "Waiting for GeoServer..."
    sleep 5
  done
}

create_workspace() {
  code=$(curl -s -o /dev/null -w "%{http_code}" -u "$AUTH" "$GS_URL/rest/workspaces/$WORKSPACE.xml")
  if [ "$code" = "404" ]; then
    curl -s -u "$AUTH" -XPOST -H "Content-Type: text/xml" \
      -d "<workspace><name>$WORKSPACE</name><namespace><uri>$NAMESPACE</uri></namespace></workspace>" \
      "$GS_URL/rest/workspaces" >/dev/null
    echo "Workspace created"
  else
    echo "Workspace exists"
  fi
}

create_store() {
  code=$(curl -s -o /dev/null -w "%{http_code}" -u "$AUTH" "$GS_URL/rest/workspaces/$WORKSPACE/datastores/$STORE.xml")
  if [ "$code" = "404" ]; then
    curl -s -u "$AUTH" -XPOST -H "Content-Type: text/xml" \
      -d "<dataStore>
            <name>$STORE</name>
            <connectionParameters>
              <host>postgis</host>
              <port>5432</port>
              <database>gis</database>
              <schema>public</schema>
              <user>gisuser</user>
              <passwd>gispass</passwd>
              <dbtype>postgis</dbtype>
            </connectionParameters>
          </dataStore>" \
      "$GS_URL/rest/workspaces/$WORKSPACE/datastores" >/dev/null
    echo "DataStore created"
  else
    echo "DataStore exists"
  fi
}

publish_layer() {
  layer="$1"
  code=$(curl -s -o /dev/null -w "%{http_code}" -u "$AUTH" "$GS_URL/rest/workspaces/$WORKSPACE/datastores/$STORE/featuretypes/$layer.xml")
  if [ "$code" = "404" ]; then
    curl -s -u "$AUTH" -XPOST -H "Content-Type: text/xml" \
      -d "<featureType><name>$layer</name><nativeName>$layer</nativeName><srs>EPSG:4326</srs></featureType>" \
      "$GS_URL/rest/workspaces/$WORKSPACE/datastores/$STORE/featuretypes" >/dev/null
    echo "Layer $layer published"
  else
    echo "Layer $layer exists"
  fi
}

wait_for_geoserver
create_workspace
create_store
publish_layer buildings
publish_layer roads
publish_layer poi

echo "GeoServer initialization complete"
