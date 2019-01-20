#!/bin/bash

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

product_name=$1
resource_template_name=$2

resource_configuration=$(eval_jq_templates "$resource_template_name" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")

product_guid=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  curl --silent --path /api/v0/staged/products \
  | jq -r --arg product_name "$product_name" \
    '.[] | select(.installation_name==$product_name) | .guid')

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
