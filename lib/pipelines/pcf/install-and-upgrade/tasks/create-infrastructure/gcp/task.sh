#!/bin/bash
set -eu

root=$PWD

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
  ${TERRAFORM_TEMPLATES_PATH}

echo terraform apply \
  -auto-approve \
  -parallelism=5 \
  ${TERRAFORM_TEMPLATES_PATH}

output_json=$(terraform output -json -state=.terraform/terraform.tfstate)
pub_ip_global_pcf=$(echo $output_json | jq --raw-output '.pub_ip_global_pcf.value')
pub_ip_ssh_and_doppler=$(echo $output_json | jq --raw-output '.pub_ip_ssh_and_doppler.value')
pub_ip_ssh_tcp_lb=$(echo $output_json | jq --raw-output '.pub_ip_ssh_tcp_lb.value')
pub_ip_opsman=$(echo $output_json | jq --raw-output '.pub_ip_opsman.value')

echo "Please configure DNS as follows:"
echo "----------------------------------------------------------------------------------------------"
echo "*.${SYSTEM_DOMAIN} == ${pub_ip_global_pcf}"
echo "*.${APPS_DOMAIN} == ${pub_ip_global_pcf}"
echo "ssh.${SYSTEM_DOMAIN} == ${pub_ip_ssh_and_doppler}"
echo "doppler.${SYSTEM_DOMAIN} == ${pub_ip_ssh_and_doppler}"
echo "loggregator.${SYSTEM_DOMAIN} == ${pub_ip_ssh_and_doppler}"
echo "tcp.${PCF_ERT_DOMAIN} == ${pub_ip_ssh_tcp_lb}"
echo "opsman.${PCF_ERT_DOMAIN} == ${pub_ip_opsman}"
echo "----------------------------------------------------------------------------------------------"
