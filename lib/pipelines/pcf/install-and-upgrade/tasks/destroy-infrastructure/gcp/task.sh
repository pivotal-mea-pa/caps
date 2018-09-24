#!/bin/bash

source ~/scripts/opsman-func.sh
root=$PWD

[[ -n "$TRACE" ]] && set -x
set -eu

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_SERVICE_ACCOUNT_KEY" > $root/gcp_service_account_key.json

export GOOGLE_CREDENTIALS=$root/gcp_service_account_key.json
export GOOGLE_PROJECT=${GCP_PROJECT_ID}
export GOOGLE_REGION=${GCP_REGION}

TERRAFORM_TEMPLATES_PATH=automation/lib/pipelines/pcf/install-and-upgrade/terraform/gcp
if [[ -n $TEMPLATE_OVERRIDE_PATH && -d $TEMPLATE_OVERRIDE_PATH ]]; then
  cp -r $TEMPLATE_OVERRIDE_PATH/ $TERRAFORM_TEMPLATES_PATH
fi

if [[ "$(opsman::check_available "https://$OPSMAN_HOST")" == "available" ]]; then
  om \
    --target https://$OPSMAN_HOST \
    --skip-ssl-validation \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    delete-installation
fi

echo "Deleting provisioned infrastructure..."

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${GCP_RESOURCE_PREFIX}" \
  ${TERRAFORM_TEMPLATES_PATH}

backend_type=$(cat .terraform/terraform.tfstate | jq -r .backend.type)
cat << ---EOF > backend.tf
terraform {
  backend "$backend_type" {}
}
---EOF

set +e

i=0
terraform destroy -force -state .terraform/terraform.tfstate
while [[ $? -ne 0 && $i -lt 2 ]]; do
  # Retry destroy as sometimes destroy may fail due to IaaS timeouts
  i=$(($i+1))
  terraform destroy -force -state .terraform/terraform.tfstate
done
exit $?
