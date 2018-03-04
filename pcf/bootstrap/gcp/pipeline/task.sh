#!/bin/bash

set -euo pipefail

echo "$GOOGLE_CREDENTIALS_JSON" > .gcp-service-account.json
export GOOGLE_CREDENTIALS=$(pwd)/.gcp-service-account.json
gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS

TERRAFORM_PARAMS_PATH=automation/pcf/bootstrap/gcp/params
INSTALL_PCF_PIPELINE_PATH=automation/pcf/install-pcf/pipeline
INSTALL_PCF_PATCHES=automation/pcf/install-pcf/patches

terraform init $TERRAFORM_PARAMS_PATH

#
# Configure install PCF pipeline
#

terraform apply -auto-approve \
  -var "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -var "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -var "params_template_file=$INSTALL_PCF_PIPELINE_PATH/gcp/params.yml" \
  -var "params_file=params.yml" \
  $TERRAFORM_PARAMS_PATH >/dev/null

set -x

cp $INSTALL_PCF_PIPELINE_PATH/gcp/${PCF_PAS_RUNTIME_TYPE}-pipeline.yml pipeline0.yml
i=0 && j=1
for p in $(echo -e "$PRODUCTS"); do 
  product_name=${p%:*}
  slug_and_version=${p#*:}
  product_slug=${slug_and_version%/*}
  product_version=${slug_and_version#*/}

  eval "echo \"$(cat $INSTALL_PCF_PATCHES/install-tile-patch.yml)\"" \
    > ${product_name}-patch.yml

  cat pipeline$i.yml \
    | yaml_patch -o ${product_name}-patch.yml \
    > pipeline$j.yml

  i=$(($i+1)) && j=$(($j+1))
done

[[ $i -ne 0 ]] && \
  cat pipeline$i.yml \
    | yaml_patch -o $INSTALL_PCF_PATCHES/schedule-patch.yml > pipeline0.yml

set +x

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

fly -t default set-pipeline -n \
  -p install-pcf \
  -c pipeline0.yml \
  -v "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -v "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -l params.yml >/dev/null

# Unpause the pipeline. The pipeline jobs will rerun in 
# an idempotent manner if a prior installation is found.
fly -t default unpause-pipeline -p install-pcf

# set +e
# bootstrap_state_job_status=$(fly -t default watch \
#   -j install-pcf/bootstrap-terraform-state 2>&1)

# if [[ "$bootstrap_state_job_status" == "error: job has no builds" ]]; then

#   result=0
#   gsutil ls "gs://$PCF_PAS_STATE_BUCKET" | grep terraform.tfstate >/dev/null 2>&1
#   [[ $? -eq 0 ]] && \
#     result=$(gsutil cat "gs://$PCF_PAS_STATE_BUCKET/terraform.tfstate" | jq '.modules[0].resources | length')

#   if [[ $result -eq 0 ]]; then
#     set -e

#     # Bootstrap the Terraform state if it is 
#     # empty and wait until the job finishes
#     fly -t default trigger-job -j install-pcf/bootstrap-terraform-state
#     fly -t default watch -j install-pcf/bootstrap-terraform-state

#     # Start the install by starting the upload-opsman-image job 
#     fly -t default trigger-job -j install-pcf/upload-opsman-image
#   else
#     echo "Terraform state is not empty so the install pipeline will not be run!"
#   fi
# else
#   set -e
# fi

fly -t default trigger-job -j install-pcf/bootstrap-terraform-state
fly -t default watch -j install-pcf/bootstrap-terraform-state
fly -t default trigger-job -j install-pcf/upload-opsman-image
