#!/bin/bash

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

TEMPLATE_PATH=automation/lib/pipelines/pcf/install-and-upgrade/templates/pks
TEMPLATE_OVERRIDE_PATH=automation-extensions/$TEMPLATE_OVERRIDE_PATH

om-linux \
  --skip-ssl-validation \
  --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  configure-bosh \
  --iaas-configuration "$(eval_jq_templates "iaas_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "IAAS")" \
  --director-configuration "$(eval_jq_templates "director_config" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "IAAS")" \
  --az-configuration "$(eval_jq_templates "az_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "IAAS")" \
  --networks-configuration "$(eval_jq_templates "network_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "IAAS")" \
  --network-assignment "$(eval_jq_templates "network_assignment" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "IAAS")" \
  --security-configuration "$(eval_jq_templates "security_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "IAAS")" \
  --resource-configuration "$(eval_jq_templates "resource_configuration" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "IAAS")"
