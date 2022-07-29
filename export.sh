#!/bin/bash

set -euo pipefail

. config.sh
SELF="$0"

fetch() {
  curl -fsSL -H "Authorization: Bearer $API_KEY" "$GRAFANA_URL/api/$1"
}

if [[ $# -eq 0 ]]; then
  mkdir -p "$DATA_DIR"
  
  echo 'Exporting data sources...'
  fetch 'datasources/' \
    | jq \
    >"$DATA_DIR/datasources.json"
  echo 'Data sources exported'

  echo 'Exporting alert notifications...'
  fetch 'alert-notifications/' \
    | jq \
    >"$DATA_DIR/alert-notifications.json"
  echo 'Alert notifications exported'

  echo 'Exporting dashboards...'
  fetch 'search/?type=dash-db' \
    | jq -r '.[] | (.uid + " " + .uri)' \
    | xargs -n2 -P0 "$SELF" DB
  echo 'Dashboards exported'
elif [[ $1 = DB ]]; then
  uid=$2
  uri=$3
  id=${uri:3}
  file="$id.json"
  dir="$DATA_DIR/dashboards"
  mkdir -p "$dir"
  fetch "dashboards/uid/$uid" >"$dir/$file"
  echo "  - $id"
else
  echo 'Invalid arguments' >&2
  exit 1
fi
