#!/bin/bash

source ~/scripts/opsman-func.sh
root=$PWD

[[ -n "$TRACE" ]] && set -x
set -e

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
      || -z $VSPHERE_PASSWORD ]]; then
    
      echo "ERROR! Connection and credential environment for '$IAAS' has not be set."
        exit 1
    fi

    export GOVC_URL="https://$VSPHERE_SERVER"
    export GOVC_USERNAME="$VSPHERE_USER"
    export GOVC_PASSWORD="$VSPHERE_PASSWORD"
    export GOVC_INSECURE=$VSPHERE_ALLOW_UNVERIFIED_SSL
	
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

TERRAFORM_TEMPLATES_PATH=automation/lib/pipelines/pcf/install-and-upgrade/terraform/${IAAS}/infrastructure
if [[ -n $TEMPLATE_OVERRIDE_PATH && -d $TEMPLATE_OVERRIDE_PATH ]]; then
  cp -r ${TEMPLATE_OVERRIDE_PATH}/${IAAS} $TERRAFORM_TEMPLATES_PATH
fi

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${DEPLOYMENT_PREFIX}" \
  ${TERRAFORM_TEMPLATES_PATH}

exit 1

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
