#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

# Retrieve bosh credentials from Ops Manager API and set BOSH envrionment

if [[ -n "$OPSMAN_USERNAME" ]]; then
  opsman::login $OPSMAN_HOST $OPSMAN_USERNAME $OPSMAN_PASSWORD ''
elif [[ -n "$OPSMAN_CLIENT_ID" ]]; then
  opsman::login_client $OPSMAN_HOST $OPSMAN_CLIENT_ID $OPSMAN_CLIENT_SECRET ''
else
  echo "ERROR! Pivotal Operations Manager credentials were not provided."
  exit 1
fi

export BOSH_ENVIRONMENT=$(opsman::get_director_ip)
export BOSH_CA_CERT=$(opsman::download_bosh_ca_cert)
export BOSH_CLIENT='ops_manager'
export BOSH_CLIENT_SECRET=$(opsman::get_director_client_secret ops_manager)

bosh::login_client "$BOSH_CA_CERT" "$BOSH_ENVIRONMENT" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"

# Retrieve opsman certificate
OPSMAN_CA_CERT=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  certificate-authorities \
  --format json \
  | jq -r '.[] | select(.issuer | match("Pivotal")) | .cert_pem')

latest_release_version=$(bosh releases | awk '/^patch-harbor/{ print $2 }' | head -1)
release_version=${latest_release_version%\**}

# Create Bosh runtime-config to patch Harbor as it does not
# correctly configure the self-signed CA root certificate
# for validation when using self-signed certificates for UAA.
if [[ -n $release_version ]]; then
  
  cat << ---EOF > harbor_runtime-config.yml
---
releases:
- name: patch-harbor
  version: $release_version

addons:
- name: patch-harbor
  jobs:
  - name: patch-harbor
    release: patch-harbor
  properties:
    opsman_ca_cert: |
$(echo -e "$OPSMAN_CA_CERT" | sed 's|^|      |g')
  include:
    jobs:
    - name: harbor
      release: harbor-container-registry
---EOF

  bosh --non-interactive \
    update-config \
    --name=patch_harbor \
    --type=runtime \
    harbor_runtime-config.yml
fi

# If Harbor deployment exists then re-run its deployment to apply patch
# harbor_deployment=$(bosh::deployment harbor-.*)
# if [[ -n $harbor_deployment ]]; then

#   bosh \
#     --deployment=${harbor_deployment} \
#     manifest \
#     > $harbor_deployment.yml

#   bosh --non-interactive \
#     --deployment=${harbor_deployment} \
#     deploy \
#     $harbor_deployment.yml
# fi
