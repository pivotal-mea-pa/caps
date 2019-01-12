#!/bin/bash

source ~/scripts/opsman-func.sh
root=$PWD

[[ -n "$TRACE" ]] && set -x
set -e

#
# Upload Opsman OVA to VCenter
#
function upload_opsman_to_vsphere() {

  set -eu
  
  ova_file_path=$(find ./pivnet-product -name *.ova | sort | head -1)
  vm_folder=/${VCENTER_DATACENTER}/vm/${VCENTER_VMS_PATH}

  set +e
  govc ls ${vm_folder} | grep ${name} >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    govc folder.create "${vm_folder}" >/dev/null 2>&1
    set -e

    govc import.spec \
      $ova_file_path \
      | jq \
        --arg image_name "$name" \
        --arg network "$OPSMAN_VCENTER_NETWORK" \
        --arg opsman_ip "$OPSMAN_IP" \
        --arg opsman_netmask "$OPSMAN_NETMASK" \
        --arg opsman_gateway "$OPSMAN_GATEWAY" \
        --arg opsman_dns_servers "$OPSMAN_DNS_SERVERS" \
        --arg opsman_ntp_servers "$OPSMAN_NTP_SERVERS" \
        --arg opsman_ssh_password "$OPSMAN_SSH_PASSWORD" \
        --arg opsman_ssh_public_key "$OPSMAN_SSH_PUBLIC_KEY" \
        --arg opsman_hostname "$OPSMAN_HOSTNAME" \
        'del(.Deployment)
        | (.PropertyMapping[] | select(.Key == "ip0")).Value = $opsman_ip
        | (.PropertyMapping[] | select(.Key == "netmask0")).Value = $opsman_netmask
        | (.PropertyMapping[] | select(.Key == "gateway")).Value = $opsman_gateway
        | (.PropertyMapping[] | select(.Key == "DNS")).Value = $opsman_dns_servers
        | (.PropertyMapping[] | select(.Key == "ntp_servers")).Value = $opsman_ntp_servers
        | (.PropertyMapping[] | select(.Key == "admin_password")).Value = $opsman_ssh_password
        | (.PropertyMapping[] | select(.Key == "public_ssh_key")).Value = $opsman_ssh_public_key
        | (.PropertyMapping[] | select(.Key == "custom_hostname")).Value = $opsman_hostname
        | .Name = $image_name
        | .DiskProvisioning = "thin"
        | .NetworkMapping[].Network = $network
        | .PowerOn = true
        | .WaitForIP = true' \
        > import-spec.json

  # Import OVA and power the VM on so that 
  # the initial configuration is applied.
    govc import.ova \
      -dc=${VCENTER_DATACENTER} \
      -ds=${OPSMAN_VCENTER_DATASTORE} \
      -folder=${vm_folder} \
      -options=import-spec.json \
      $ova_file_path 
  else
    echo "Ops Manager template '$name' exists skipping upload."
  fi
}

download_file_path=$(find ./pivnet-download -name *.tgz | sort | head -1)
tar xvzf $download_file_path

archive_name=$(basename $download_file_path)
opsman_name=${archive_name%_*}

export TF_VAR_bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET
export TF_VAR_bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX

case $IAAS in
  google)
    if [[ -n $GOOGLE_CREDENTIALS_JSON ]]; then
      echo "ERROR! A Google service key needs to be provided via the 'GOOGLE_CREDENTIALS_JSON' environment variable."
      exit 1
    fi

    echo "$GOOGLE_CREDENTIALS_JSON" > .gcp-service-account.json
    export GOOGLE_CREDENTIALS=$(pwd)/.gcp-service-account.json
    gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS
    ;;

  vsphere)
	if [[ -z $VSPHERE_SERVER
	  || -z $VSPHERE_USER
	  || -z $VSPHERE_PASSWORD ]]
  
	  echo "ERROR! Connection and credential environment for '$IAAS' has not be set."
      exit 1
    fi

    export GOVC_URL="https://$VSPHERE_SERVER"
    export GOVC_USERNAME="$VSPHERE_USER"
    export GOVC_PASSWORD="$VSPHERE_PASSWORD"
    export GOVC_INSECURE=${VSPHERE_ALLOW_UNVERIFIED_SSL:-false}
	
	upload_opsman_to_vsphere
  	
  *)
    echo "ERROR! Unrecognized IAAS type '$IAAS'."
    exit 1
esac

# If S3 access keys is provided then set them as AWS env variables
if [[ -n $S3_ACCESS_KEY_ID 
  && -n $S3_SECRET_ACCESS_KEY ]]; then
  
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION=$S3_DEFAULT_REGION
fi

exit 1

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_SERVICE_ACCOUNT_KEY" > $root/gcp_service_account_key.json

export GOOGLE_CREDENTIALS=$root/gcp_service_account_key.json
export GOOGLE_PROJECT=${GCP_PROJECT}
export GOOGLE_REGION=${GCP_REGION}

TERRAFORM_TEMPLATES_PATH=automation/lib/pipelines/pcf/install-and-upgrade/terraform/vsphere/infrastructure
if [[ -n $TEMPLATE_OVERRIDE_PATH && -d $TEMPLATE_OVERRIDE_PATH ]]; then
  cp -r $TEMPLATE_OVERRIDE_PATH/ $TERRAFORM_TEMPLATES_PATH
fi

# us: ops-manager-us/pcf-gcp-1.9.2.tar.gz -> ops-manager-us/pcf-gcp-1.9.2.tar.gz
pcf_opsman_input_path=$(grep -i 'us:.*.tar.gz' pivnet-opsmgr/*GCP.yml | cut -d' ' -f2)
# ops-manager-us/pcf-gcp-1.9.2.tar.gz -> opsman-pcf-gcp-1-9-2
export TF_VAR_pcf_opsman_image_name=$(echo $pcf_opsman_input_path | sed 's%.*/\(.*\).tar.gz%opsman-\1%' | sed 's/\./-/g')

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${DEPLOYMENT_PREFIX}" \
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
  | jq -r --arg q "'" '. | to_entries[] | "\(.key)=\($q)\(.value.value)\($q)"' \
  > upload_path/pcf-env.sh
