#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_CREDENTIALS" > $root/gcp_service_account_key.json

export GOOGLE_CREDENTIALS=$root/gcp_service_account_key.json
export GOOGLE_PROJECT=${GCP_PROJECT}
export GOOGLE_REGION=${GCP_REGION}

export TF_VAR_clusters="[]"
export TF_VAR_cluster_ids="{}"
export TF_VAR_cluster_instances="{}"

terraform init \
    -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
    -backend-config="prefix=${DEPLOYMENT_PREFIX}-k8s-clusters" \
    automation/lib/pipelines/pcf/install-and-upgrade/terraform/gcp/pks-loadbalancers

terraform destroy \
    -auto-approve \
    -var "terraform_state_bucket=${TERRAFORM_STATE_BUCKET}" \
    -var "pcf_state_prefix=${DEPLOYMENT_PREFIX}" \
    automation/lib/pipelines/pcf/install-and-upgrade/terraform/gcp/pks-loadbalancers
