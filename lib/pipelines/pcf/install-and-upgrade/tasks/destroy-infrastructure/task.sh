#!/bin/bash

source ~/scripts/opsman-func.sh

[[ -n "$TRACE" ]] && set -x
set -eu

terraform_templates_path=automation/lib/pipelines/pcf/install-and-upgrade/terraform/${IAAS}/infrastructure
if [[ -n $TEMPLATE_OVERRIDE_PATH && -d $TEMPLATE_OVERRIDE_PATH ]]; then
  cp -r ${TEMPLATE_OVERRIDE_PATH}/${IAAS} $terraform_templates_path
fi

# Delete infrastructure provisioned by Ops Manager
if [[ "$(opsman::check_available "https://$OPSMAN_HOST")" == "available" ]]; then
  om \
    --target https://$OPSMAN_HOST \
    --skip-ssl-validation \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    delete-installation
fi

# Initialize IaaS environment variables
case $IAAS in
  google)
    if [[ -n $GCP_SERVICE_ACCOUNT_KEY ]]; then
      echo "ERROR! A Google service key JSON contents need to be provided via the 'GCP_SERVICE_ACCOUNT_KEY' environment variable."
      exit 1
    fi

    echo "$GCP_SERVICE_ACCOUNT_KEY" > .gcp-service-account.json
    export GOOGLE_CREDENTIALS=$(pwd)/.gcp-service-account.json
    gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS

    export GOOGLE_PROJECT=${GCP_PROJECT}
    export GOOGLE_REGION=${GCP_REGION}

    terraform init \
      -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
      -backend-config="prefix=${DEPLOYMENT_PREFIX}" \
      $terraform_templates_path
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

    # If S3 access keys are provided then set them as AWS env variables
    if [[ -z $S3_ACCESS_KEY_ID 
      || -z $S3_SECRET_ACCESS_KEY ]]; then
      
      echo "ERROR! '$IAAS' requires an S3 backend to save Terraform state."
      exit 1
    fi

    export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
    export AWS_DEFAULT_REGION=$S3_DEFAULT_REGION
    
    # Default is to use an S3 backend
    if [[ -n $TF_STATE_S3_ENDPOINT ]]; then
      terraform init \
        -backend-config="bucket=$TERRAFORM_STATE_BUCKET" \
        -backend-config="key=$DEPLOYMENT_PREFIX" \
        -backend-config="endpoint=$TF_STATE_S3_ENDPOINT" \
        $terraform_templates_path
    else
      # Use AWS S3 as default
      terraform init \
        -backend-config="bucket=$TERRAFORM_STATE_BUCKET" \
        -backend-config="key=$DEPLOYMENT_PREFIX" \
        $terraform_templates_path
    fi
    ;;

  *)
    echo "ERROR! Unrecognized IAAS type '$IAAS'."
    exit 1
    ;;
esac

# Delete infrastructure
echo "Deleting provisioned infrastructure..."

# backend_type=$(cat .terraform/terraform.tfstate | jq -r .backend.type)
# cat << ---EOF > backend.tf
# terraform {
#   backend "$backend_type" {}
# }
# ---EOF

set +e

i=0
terraform destroy -force -state .terraform/terraform.tfstate $terraform_templates_path
while [[ $? -ne 0 && $i -lt 2 ]]; do
  # Retry destroy as sometimes destroy may fail due to IaaS timeouts
  i=$(($i+1))
  terraform destroy -force -state .terraform/terraform.tfstate $terraform_templates_path
done
exit $?
