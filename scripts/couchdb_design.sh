#!/bin/bash

THX_PREFIX='THX01'

echo $THX_PREFIX ./conf/.thx_prefix

# or use ENV_VAR COUCH_USER and COUCH_PASS

if [[ -z $COUCH_USER ]]; then
  echo "COUCH_USER environment variable must be set."
  exit 1
fi

if [[ -z $COUCH_PASS ]]; then
  echo "COUCH_PASS environment variable must be set."
  exit 1
fi

if [[ -z $COUCH_URL ]]; then
  echo "COUCH_URL environment variable must be set."
  exit 1
fi

# May require additional authentication based on the CouchDB setup
curl -X PUT http://$COUCH_USER:$COUCH_PASS@$COUCH_URL:5984/${THX_PREFIX}_managed_devices/_design/devicelib -d @design/design_deviceslib.json
curl -X PUT http://$COUCH_USER:$COUCH_PASS@$COUCH_URL:5984/${THX_PREFIX}_managed_users/_design/users -d @design/design_users.json
curl -X PUT http://$COUCH_USER:$COUCH_PASS@$COUCH_URL:5984/${THX_PREFIX}_managed_logs/_design/logs -d @design/design_logs.json
curl -X PUT http://$COUCH_USER:$COUCH_PASS@$COUCH_URL:5984/${THX_PREFIX}_managed_builds/_design/builds -d @design/design_builds.json
