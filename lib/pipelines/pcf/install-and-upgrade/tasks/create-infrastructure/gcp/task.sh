#!/bin/bash

source ~/scripts/opsman-func.sh
root=$PWD

set -eu

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_SERVICE_ACCOUNT_KEY" > $root/gcp_service_account_key.json

export GOOGLE_CREDENTIALS=$root/gcp_service_account_key.json
export GOOGLE_PROJECT=${GCP_PROJECT_ID}
export GOOGLE_REGION=${GCP_REGION}

# us: ops-manager-us/pcf-gcp-1.9.2.tar.gz -> ops-manager-us/pcf-gcp-1.9.2.tar.gz
pcf_opsman_input_path=$(grep -i 'us:.*.tar.gz' pivnet-opsmgr/*GCP.yml | cut -d' ' -f2)
# ops-manager-us/pcf-gcp-1.9.2.tar.gz -> opsman-pcf-gcp-1-9-2
export TF_VAR_pcf_opsman_image_name=$(echo $pcf_opsman_input_path | sed 's%.*/\(.*\).tar.gz%opsman-\1%' | sed 's/\./-/g')

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${GCP_RESOURCE_PREFIX}" \
  ${TERRAFORM_TEMPLATES_PATH}

terraform plan \
  -out=terraform.plan \
  ${TERRAFORM_TEMPLATES_PATH}

terraform apply \
  -auto-approve \
  -parallelism=5 \
  terraform.plan

# Seems to be a bug in terraform where 'output' and 'taint' command are 
# unable to load the backend state when the working directory does not 
# have the backend resource template file.
backend_type=$(cat .terraform/terraform.tfstate | jq -r .backend.type)
cat << ---EOF > backend.tf
terraform {
  backend "$backend_type" {}
}
---EOF

terraform output -json \
  -state .terraform/terraform.tfstate \
  > upload_path/terraform-output.json
