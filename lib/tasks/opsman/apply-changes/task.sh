#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

echo "Applying changes on Ops Manager @ ${OPSMAN_HOST}"

om \
  --target "https://${OPSMAN_HOST}" \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  apply-changes \
  --ignore-warnings
