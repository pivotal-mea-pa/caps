#!/bin/bash

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

TEMPLATE_PATH=automation/lib/pipelines/pcf/install-and-upgrade/templates/director
TEMPLATE_OVERRIDE_PATH=automation-extensions/$TEMPLATE_OVERRIDE_PATH

iaas_configuration=$(eval_jq_templates "iaas_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")
director_configuration=$(eval_jq_templates "director_config" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")
az_configuration=$(eval_jq_templates "az_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")
networks_configuration=$(eval_jq_templates "network_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")
network_assignment=$(eval_jq_templates "network_assignment" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")
security_configuration=$(eval_jq_templates "security_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")
resource_configuration=$(eval_jq_templates "resource_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")

om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  configure-director \
  --iaas-configuration "$iaas_configuration" \
  --director-configuration "$director_configuration" \
  --az-configuration "$az_configuration" \
  --networks-configuration "$networks_configuration" \
  --network-assignment "$network_assignment" \
  --security-configuration "$security_configuration" \
  --resource-configuration "$resource_configuration"
