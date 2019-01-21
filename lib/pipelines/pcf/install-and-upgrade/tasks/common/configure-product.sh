#!/bin/bash

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

product_guid=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  curl --silent --path /api/v0/staged/products \
  | jq -r --arg product_name "$PRODUCT_NAME" \
    '.[] | select(.type==$product_name) | .guid')

#
# Update director resources
#

automation/lib/pipelines/pcf/install-and-upgrade/tasks/common/configure-resources.sh \
  "$PRODUCT_NAME" "resources" ""

#
# Update product network and azs
# - https://opsman.sandbox.demo3.pocs.pcfs.io/docs#configuring-networks-and-azs
#

networks_and_azs=$(eval_jq_templates "network" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")

om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  curl \
  --silent --path /api/v0/staged/products/$product_guid/networks_and_azs \
  --request PUT --data "$(
    jq -n \
      --argjson networks_and_azs "$networks_and_azs" \
      '{
        "networks_and_azs": $networks_and_azs
      }'
  )"

#
# Update product properties
# - https://opsman.sandbox.demo3.pocs.pcfs.io/docs#updating-a-simple-property
#

properties=$(eval_jq_templates "properties" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")

om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  curl \
  --silent --path /api/v0/staged/products/$product_guid/properties \
  --request PUT --data "$(
    jq -n \
      --argjson properties "$properties" \
      '{
        "properties": $properties
      }'
  )"

#
# Set all errands to that are configured 
# to run always to "when-changed" and 
# disable any specified errands at the 
# same time.
#

product_guid=$(om \
  --target "https://${OPSMAN_HOST}" \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "$OPSMAN_USERNAME" \
  --password "$OPSMAN_PASSWORD" \
  curl --path /api/v0/staged/products | \
  jq -r --arg product $PRODUCT_NAME '.[] | select(.type == $product) | .guid'  
)

errands=$(om \
  --target "https://${OPSMAN_HOST}" \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "$OPSMAN_USERNAME" \
  --password "$OPSMAN_PASSWORD" \
  curl --path /api/v0/staged/products/$product_guid/errands
)

ERRAND_DEFAULT_IF_ENABLED=${ERRAND_DEFAULT_IF_ENABLED:-true}

updated_errands=$(echo $errands | jq \
  --arg to_enable "$ERRANDS_TO_ENABLE" \
  --arg to_disable "$ERRANDS_TO_DISABLE" \
  --arg errand_default_if_enabled "$ERRAND_DEFAULT_IF_ENABLED" \
  '.errands[] 
  | 
  select(.post_deploy != null) 
  | 
  if ($to_disable == "all") or (.name | inside($to_disable)) then 
      .post_deploy = false
  elif (.name | inside($to_enable)) then 
      .post_deploy = $errand_default_if_enabled
  elif (.post_deploy == true) then
      .post_deploy = $errand_default_if_enabled
  else
      .
  end' | jq -s '{"errands": . }'
)

om \
  --target "https://${OPSMAN_HOST}" \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "$OPSMAN_USERNAME" \
  --password "$OPSMAN_PASSWORD" \
  curl \
  --path /api/v0/staged/products/$product_guid/errands \
  --request PUT --data "$updated_errands"
