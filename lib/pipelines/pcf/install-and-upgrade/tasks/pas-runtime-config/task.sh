#!/bin/bash

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

# Apply Terraform templates to configure PAS orgs 
# and users.

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${DEPLOYMENT_PREFIX}-pas-config" \
  automation/lib/pipelines/pcf/install-and-upgrade/terraform/pas-runtime

terraform apply -auto-approve \
  -var "opsman_target=${OPSMAN_HOST}" \
  -var "opsman_client_id=${OPSMAN_CLIENT_ID}" \
  -var "opsman_client_secret=${OPSMAN_CLIENT_SECRET}" \
  -var "opsman_username=${OPSMAN_USERNAME}" \
  -var "opsman_password=${OPSMAN_PASSWORD}" \
  -var "infrastructure_state_bucket=${TERRAFORM_STATE_BUCKET}" \
  -var "infrastructure_state_prefix=${DEPLOYMENT_PREFIX}" \
  automation/lib/pipelines/pcf/install-and-upgrade/terraform/pas-runtime
