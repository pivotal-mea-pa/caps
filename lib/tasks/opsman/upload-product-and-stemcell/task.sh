#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

tar xvzf pivnet-download/*.tgz

STEMCELL_FILE_PATH=$(find ./pivnet-product -name *.tgz | sort | head -1)
if [[ -n ${STEMCELL_FILE_PATH} ]]; then

    om -t https://$OPSMAN_HOST \
      --client-id "${OPSMAN_CLIENT_ID}" \
      --client-secret "${OPSMAN_CLIENT_SECRET}" \
      --username "$OPSMAN_USERNAME" \
      --password  "$OPSMAN_PASSWORD" \
      --skip-ssl-validation \
      upload-stemcell \
      --stemcell $STEMCELL_FILE_PATH
fi

# Should the slug contain more than one product, pick only the first.
TILE_FILE_PATH=$(find ./pivnet-product -name *.pivotal | sort | head -1)
om -t https://$OPSMAN_HOST \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "$OPSMAN_USERNAME" \
  --password  "$OPSMAN_PASSWORD" \
  --skip-ssl-validation \
  --request-timeout 3600 \
  upload-product \
  --product $TILE_FILE_PATH
