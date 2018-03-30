#!/bin/bash

OPSMAN_URL="https://${opsman_dns_name}"
OPSMAN_ADMIN_PASSWORD="${opsman_admin_password}"

export BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/uaac/Gemfile
bundle exec uaac target $OPSMAN_URL/uaa --skip-ssl-validation
if [[ $? -ne 0 ]]; then
  echo "Ops Manager has not been initialized."
  exit 0
fi

set -e
bundle exec uaac token owner get opsman admin -s "" -p "$OPSMAN_ADMIN_PASSWORD"

TOKEN=$(bundle exec uaac context | awk '/access_token:/{ print $2 }')
TIMESTAMP=$(date +%Y%m%d%H%M%S)

sudo mkdir -p /data/exports
sudo chown ubuntu:ubuntu /data/exports

curl -f -k "$OPSMAN_URL/api/v0/installation_asset_collection" \
  -H "Authorization: Bearer $TOKEN" \
  -X GET -o /data/exports/installation-$TIMESTAMP.zip

set +e

file /data/exports/installation-$TIMESTAMP.zip | grep 'ASCII text' >/dev/null 2>&1
if [[ $? -eq 0 ]]; then

  cat /data/exports/installation-$TIMESTAMP.zip
  echo ''
  
  rm /data/exports/installation-$TIMESTAMP.zip
  exit 1
fi

sudo chown ubuntu:ubuntu /data/exports/installation-$TIMESTAMP.zip
