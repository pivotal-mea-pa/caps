#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

echo "Applying changes on Ops Manager @ ${OPSMAN_HOST}"

if [[ $DISABLE_ERRANDS == "true" ]]; then

  staged_products=$(om \
    --target "https://${OPSMAN_HOST}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl --path /api/v0/staged/products \
    | jq -r '.[] | select(.type != "p-bosh") | .guid')

  request='{"deploy_products":"all","ignore_warnings":true,"errands":{}}'

  for product_guid in $(echo $staged_products); do

    errands=$(om \
      --target "https://${OPSMAN_HOST}" \
      --skip-ssl-validation \
      --client-id "${OPSMAN_CLIENT_ID}" \
      --client-secret "${OPSMAN_CLIENT_SECRET}" \
      --username "$OPSMAN_USERNAME" \
      --password "$OPSMAN_PASSWORD" \
      curl --path /api/v0/staged/products/$product_guid/errands)

    disabled_errands=$(echo $errands \
      | jq '.errands[] | select(.post_deploy != null) | reduce .name as $errand ({}; .[$errand] |= false)' \
      | jq -s add \
      | jq --arg product_guid "$product_guid" '[{ "key": $product_guid, "value": {"run_post_deploy":.}}]' \
      | jq 'from_entries')

    request=$(echo $request \
      | jq --argjson disabled_errands "$disabled_errands" '.errands *= $disabled_errands')
  done

  om \
    --target "https://${OPSMAN_HOST}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    curl \
    --path /api/v0/installations \
    --request POST \
    --data "$request"

elif [[ $DIRECTOR_ONLY == "true" ]]; then
  om \
    --target "https://${OPSMAN_HOST}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    apply-changes \
    --ignore-warnings \
    --skip-deploy-products

else
  om \
    --target "https://${OPSMAN_HOST}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    apply-changes \
    --ignore-warnings
fi
