#!/bin/bash

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
[[ -e terraform-output/ ]] && eval "$(cat terraform-output/pcf-env-*.sh)"

PRODUCT_NAME=pivotal-container-service
TEMPLATE_PATH=lib/pipelines/pcf/install-and-upgrade/templates/pks

INSTALLED_VERSION=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${PCFOPS_CLIENT}" \
  --client-secret "${PCFOPS_SECRET}" \
  --username "${OPSMAN_USER}" \
  --password "${OPSMAN_PASSWD}" \
  curl -path /api/v0/deployed/products \
  | jq -r --arg product_name $PRODUCT_NAME '.[] | select(.type==$product_name) | .product_version')

if [[ -n "$INSTALLED_VERSION" ]]; then
  NEW_VERSION=$(cat pivnet-product/version | cut -d'#' -f1)
  echo "The product tile '$PRODUCT_NAME' version '$INSTALLED_VERSION' has already been configured."
  echo "No further changes required to install version '$NEW_VERSION'."
  exit 0
fi

om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${PCFOPS_CLIENT}" \
  --client-secret "${PCFOPS_SECRET}" \
  --username "${OPSMAN_USER}" \
  --password "${OPSMAN_PASSWD}" \
  configure-product \
  --product-name $PRODUCT_NAME \
  --product-network "$(eval_jq_templates "network" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")" \
  --product-resources "$(eval_jq_templates "resources" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")" \
  --product-properties "$(eval_jq_templates "properties" "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH")"
