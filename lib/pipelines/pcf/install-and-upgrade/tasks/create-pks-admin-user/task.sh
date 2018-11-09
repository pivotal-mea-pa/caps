#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

echo -e "$CA_CERTS" > ca_cert.pem
uaac target $PKS_URL:8443 --ca-cert ca_cert.pem

admin_client_secret=$(om \
  --target "https://${OPSMAN_HOST}" \
  --skip-ssl-validation \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  credentials \
  --product-name "pivotal-container-service" \
  --credential-reference ".properties.pks_uaa_management_admin_client" \
  --credential-field "secret")

uaac token client get admin -s ${admin_client_secret}

set +e
uaac user get ${PKS_ADMIN_USERNAME} >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  set -e
  uaac user add ${PKS_ADMIN_USERNAME} --emails ${PKS_ADMIN_EMAIL} -p ${PKS_ADMIN_PASSWORD}
  uaac member add pks.clusters.admin pks-admin
fi
