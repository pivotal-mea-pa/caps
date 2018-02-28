#!/bin/bash

set -euo pipefail

echo "$GOOGLE_CREDENTIALS_JSON" > .gcp-service-account.json
export GOOGLE_CREDENTIALS=$(pwd)/.gcp-service-account.json

TASK_TERRAFORM_PATH=install-pas-pipeline/pcf/install-pas/pipeline/$IAAS_TYPE/terraform/params
INSTALL_PAS_PIPELINE_PATH=install-pas-pipeline/pcf/install-pas/pipeline

terraform init $TASK_TERRAFORM_PATH
  
terraform apply -auto-approve \
  -var "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -var "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -var "params_file=params.yml" \
  $TASK_TERRAFORM_PATH >/dev/null 2>&1

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

fly -t default set-pipeline -n \
  -p install-pas \
  -c $INSTALL_PAS_PIPELINE_PATH/$PCF_PAS_RUNTIME_TYPE-pipeline.yml \
  -v "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -v "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -l params.yml >/dev/null 2>&1

# Unpause the pipeline but pause uploading opsman 
# image until the terraform state has been bootstrapped
fly -t default pause-job -j install-pas/upload-opsman-image
fly -t default unpause-pipeline -p install-pas

set +e
bootstrap_state_job_status=$(fly -t default watch \
  -j install-pas/bootstrap-terraform-state 2>&1)
set -e

if [[ "$bootstrap_state_job_status" == "error: job has no builds" ]]; then

  # Bootstrap the Terraform state if it has not been 
  # done before and wait until the job finishes
  fly -t default trigger-job -j install-pas/bootstrap-terraform-state
  fly -t default watch -j install-pas/bootstrap-terraform-state
fi

fly -t default unpause-job -j install-pas/upload-opsman-image
