#!/bin/bash

set -euo pipefail

echo "$GOOGLE_CREDENTIALS_JSON" > .gcp-service-account.json
export GOOGLE_CREDENTIALS=$(pwd)/.gcp-service-account.json

TASK_TERRAFORM_PATH=automation-pipelines/pcf/install-pas/bootstrap/pipeline/terraform
TASK_PARAMS_TEMPLATE_PATH=automation-pipelines/pcf/install-pas/bootstrap/pipeline/tasks/set-install-pas-pipeline
INSTALL_PAS_PIPELINE_PATH=automation-pipelines/pcf/install-pas/pipeline

terraform init $TASK_TERRAFORM_PATH
  
terraform apply -auto-approve \
  -var "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -var "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -var "params_template_file=$TASK_PARAMS_TEMPLATE_PATH/params.yml" \
  $TASK_TERRAFORM_PATH 

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

fly -t default set-pipeline -n \
  -p install-pas \
  -c $INSTALL_PAS_PIPELINE_PATH/$PCF_PAS_RUNTIME_TYPE-pipeline.yml \
  -l params.yml >/dev/null 2>&1

fly -t default unpause-pipeline \
  -p install-pas \

fly -t default trigger-job \
  -j install-pas/bootstrap-terraform-state

fly -t default watch \
  -j install-pas/bootstrap-terraform-state

fly -t default watch \
  -j install-pas/upload-opsman-image
