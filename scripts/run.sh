#!/bin/bash

# Initialize first run
if [[ -e /.firstrun ]]; then
    /scripts/couchdb_first_run.sh
fi

# Start CouchDB
echo "Starting CouchDB..."
/usr/local/bin/couchdb &

echo "Starting Mosquitto..."
mosquitto &

echo "Starting Redis..."
redis-server &

echo "Starting THiNX..."
cd /root/thinx-device-api && node index.js

echo "Starting bash:"
bash
