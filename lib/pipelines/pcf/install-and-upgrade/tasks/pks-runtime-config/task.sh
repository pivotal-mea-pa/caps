#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_CREDENTIALS" > $root/gcp_service_account_key.json

export GOOGLE_CREDENTIALS=$root/gcp_service_account_key.json
export GOOGLE_PROJECT=${GCP_PROJECT}
export GOOGLE_REGION=${GCP_REGION}

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

harbor_deployment=$(bosh::deployment harbor-*)
$bosh -d $harbor_deployment ssh harbor-app -c \
"sudo su -l -c '
    
  export PATH=/var/vcap/bosh/bin:\$PATH

  cd /var/vcap/jobs/harbor/config
  cert_diff=\$(diff -u ca.crt uaa_ca.crt)

  if [[ -n "\$cert_diff" ]]; then
    cp /var/vcap/jobs/harbor/config/ca.crt /var/vcap/jobs/harbor/config/uaa_ca.crt

    cd /var/vcap/jobs/harbor/bin
    monit stop harbor
    ./pre-start
    monit start harbor
  fi
'"

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${DEPLOYMENT_PREFIX}-pks-config" \
  automation/lib/pipelines/pcf/install-and-upgrade/terraform/product/pks

terraform apply -auto-approve \
  -var "opsman_target=${OPSMAN_HOST}" \
  -var "opsman_client_id=${OPSMAN_CLIENT_ID}" \
  -var "opsman_client_secret=${OPSMAN_CLIENT_SECRET}" \
  -var "opsman_username=${OPSMAN_USERNAME}" \
  -var "opsman_password=${OPSMAN_PASSWORD}" \
  -var "infrastructure_state_bucket=${TERRAFORM_STATE_BUCKET}" \
  -var "infrastructure_state_prefix=${DEPLOYMENT_PREFIX}" \
  automation/lib/pipelines/pcf/install-and-upgrade/terraform/product/pks
