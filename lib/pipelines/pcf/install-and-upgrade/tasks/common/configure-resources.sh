#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

product_name=$1
resource_configuration=$2

product_guid=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  curl --silent --path /api/v0/staged/products \
  | jq -r --arg product_name "$product_name" \
    '.[] | select(.type==$product_name) | .guid')

jobs=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  curl --silent --path /api/v0/staged/products/${product_guid}/jobs)

for j in $(echo $resource_configuration | jq -r '. | keys | .[]'); do

  job_guid=$(echo $jobs \
    | jq -r --arg job_name "$j" \
      '.jobs[] | select(.name==$job_name) | .guid')

  resource_config=$(echo $resource_configuration \
    | jq --arg job_name "$j" \
      '. | to_entries[] | select(.key==$job_name) | .value')

  curr_resource_config=$(om \
    --skip-ssl-validation \
    --target "https://${OPSMAN_HOST}" \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl --silent --path /api/v0/staged/products/${product_guid}/jobs/$job_guid/resource_config)

  om \
    --skip-ssl-validation \
    --target "https://${OPSMAN_HOST}" \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl \
    --silent --path /api/v0/staged/products/${product_guid}/jobs/$job_guid/resource_config \
    --request PUT --data "$(jq -n \
      --argjson curr_resource_config "$curr_resource_config" \
      --argjson resource_config "$resource_config" \
      '$curr_resource_config * $resource_config'
    )"
done
