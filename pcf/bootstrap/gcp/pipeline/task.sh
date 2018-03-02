#!/bin/bash

set -euo pipefail

echo "$GOOGLE_CREDENTIALS_JSON" > .gcp-service-account.json
export GOOGLE_CREDENTIALS=$(pwd)/.gcp-service-account.json
gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS

TERRAFORM_PARAMS_PATH=automation/pcf/bootstrap/$IAAS_TYPE/params
INSTALL_PAS_PIPELINE_PATH=automation/pcf/install-pas/pipeline/$IAAS_TYPE

terraform init $TERRAFORM_PARAMS_PATH

#
# Configure install-pas pipeline
#

terraform apply -auto-approve \
  -var "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -var "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -var "params_template_file=$INSTALL_PAS_PIPELINE_PATH/params.yml" \
  -var "params_file=params.yml" \
  $TERRAFORM_PARAMS_PATH >/dev/null

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

fly -t default set-pipeline -n \
  -p install-pas \
  -c $INSTALL_PAS_PIPELINE_PATH/${PCF_PAS_RUNTIME_TYPE}-pipeline.yml \
  -v "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -v "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -l params.yml >/dev/null

# Unpause the pipeline
fly -t default unpause-pipeline -p install-pas

set +e
bootstrap_state_job_status=$(fly -t default watch \
  -j install-pas/bootstrap-terraform-state 2>&1)

if [[ "$bootstrap_state_job_status" == "error: job has no builds" ]]; then

  result=0
  gsutil ls "gs://$PCF_PAS_STATE_BUCKET" | grep terraform.tfstate >/dev/null 2>&1
  [[ $? -eq 0 ]] && \
    result=$(gsutil cat "gs://$PCF_PAS_STATE_BUCKET/terraform.tfstate" | jq '.modules[0].resources | length')

  if [[ $result -eq 0 ]]; then
    set -e

    # Bootstrap the Terraform state if it is 
    # empty and wait until the job finishes
    fly -t default trigger-job -j install-pas/bootstrap-terraform-state
    fly -t default watch -j install-pas/bootstrap-terraform-state

    # Start the install by starting the upload-opsman-image job 
    fly -t default trigger-job -j install-pas/upload-opsman-image
  else
    echo "Terraform state is not empty so the install pipeline will not be run!"
  fi
else
  set -e
fi
