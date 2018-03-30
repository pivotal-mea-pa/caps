#!/bin/bash
set -eu

root=$PWD

export GOOGLE_CREDENTIALS=${GCP_SERVICE_ACCOUNT_KEY}
export GOOGLE_PROJECT=${GCP_PROJECT_ID}
export GOOGLE_REGION=${GCP_REGION}

source "${root}/pcf-pipelines/functions/check_opsman_available.sh"

opsman_available=$(check_opsman_available $OPSMAN_DOMAIN_OR_IP_ADDRESS)
if [[ $opsman_available == "available" ]]; then
  om-linux \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --skip-ssl-validation \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    delete-installation
fi

# Create cliaas config

echo "$GCP_SERVICE_ACCOUNT_KEY" > gcpcreds.json
cat > cliaas_config.yml <<EOF
gcp:
  credfile: gcpcreds.json
  zone: ${OPSMAN_ZONE}
  project: ${GCP_PROJECT_ID}
  disk_image_url: dontmatter
EOF

terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${GCP_RESOURCE_PREFIX}" \
  ${TERRAFORM_TEMPLATES_PATH}

echo "Deleting provisioned infrastructure..."
terraform destroy -force \
  ${TERRAFORM_TEMPLATES_PATH}
