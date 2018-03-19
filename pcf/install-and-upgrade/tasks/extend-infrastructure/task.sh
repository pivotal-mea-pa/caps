#!/bin/bash

set -euo pipefail

cp -r pcf-pipelines-orig/* pcf-pipelines/

patch=${PATCH:-yes}
tf_template_path=${TF_TEMPLATE_PATH:-automation-pipelines/pcf/install-and-upgrade/pipeline/$IAAS_TYPE/terraform}

# Copy terraform templates that patch the pcf-piplines 
# templates and attaches PCF VPC it to the bootstrap VPC.
if [[ $patch == yes ]]; then 
    cp $tf_template_path/* pcf-pipelines/install-pcf/$IAAS_TYPE/terraform/
else
    rm -fr pcf-pipelines/install-pcf/$IAAS_TYPE/terraform
    cp -r $tf_template_path pcf-pipelines/install-pcf/$IAAS_TYPE/terraform
fi

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_SERVICE_ACCOUNT_KEY" \
    > pcf-pipelines/install-pcf/$IAAS_TYPE/terraform/gcp_service_account_key.json