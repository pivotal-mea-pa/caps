#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_CREDENTIALS" > $root/gcp_service_account_key.json

export GOOGLE_CREDENTIALS=$root/gcp_service_account_key.json
export GOOGLE_PROJECT=${GCP_PROJECT}
export GOOGLE_REGION=${GCP_REGION}

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${DEPLOYMENT_PREFIX}-k8s-clusters" \
  automation/lib/pipelines/pcf/install-and-upgrade/terraform/pks-loadbalancers/google

set +e
terraform apply \
  -auto-approve \
  -var "infrastructure_state_bucket=${TERRAFORM_STATE_BUCKET}" \
  -var "infrastructure_state_prefix=${DEPLOYMENT_PREFIX}" \
  automation/lib/pipelines/pcf/install-and-upgrade/terraform/pks-loadbalancers/google

# The re-ordering of cluster resources in the enumerations
# can cause load balancer artifacts to be deleted and recreated.
# This can result in duplicate resource failures and will
# go away when terraform apply is rerun. This issue will be
# fixed when more flexible logical constructs are introduced
# Terraform HCL2.
if [[ $? -ne 0 ]]; then
  set -e
  terraform apply \
    -auto-approve \
    -var "infrastructure_state_bucket=${TERRAFORM_STATE_BUCKET}" \
    -var "infrastructure_state_prefix=${DEPLOYMENT_PREFIX}" \
    automation/lib/pipelines/pcf/install-and-upgrade/terraform/pks-loadbalancers/google
fi
