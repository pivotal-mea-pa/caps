#!/bin/bash

OPSMAN_URL="https://${opsman_dns_name}"
OPSMAN_ADMIN_PASSWORD="${opsman_admin_password}"

# Import installaton if one was found

if [[ -e /data/exports ]]; then
  installation_zip=$(ls -ltr /data/exports/installation*.zip | tail -1 | awk '{ print $9 }')
fi

if [[ ! -e /home/ubuntu/.import_checked ]] &&
  [[ -n $installation_zip ]]; then
  echo "Importing configuration found at '$installation_zip' to new appliance."
  
  set -e
  curl -k "https://$OPSMAN_URL/api/v0/installation_asset_collection" \
    -X POST \
    -F "installation[file]=@$installation_zip" \
    -F "passphrase=$OPSMAN_ADMIN_PASSWORD"

  if [[ $? -eq 0 ]]; then
    sleep 10
    set +e
    
    export BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/uaac/Gemfile

    bundle exec uaac target https://$OPSMAN_URL/uaa --skip-ssl-validation > /dev/null 2>&1
    while [[ $? -ne 0 ]]; do
      echo "Waiting for Ops Manager UAA to initialize."
      sleep 5
      bundle exec uaac target https://$OPSMAN_URL/uaa --skip-ssl-validation > /dev/null 2>&1
    done
  fi
fi
touch .import_checked
