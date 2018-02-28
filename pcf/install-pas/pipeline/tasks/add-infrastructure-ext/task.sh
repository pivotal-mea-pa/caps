#!/bin/bash

set -euo pipefail

cp -r pcf-pipelines-orig/* pcf-pipelines/

# Copy terraform templates that patch the pcf-piplines 
# templates and attaches PCF VPC it to the bootstrap VPC.
cp automation-pipelines/pcf/install-pas/pipeline/$IAAS_TYPE/terraform/infrastructure-ext/* \
    pcf-pipelines/install-pcf/$IAAS_TYPE/terraform/

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_SERVICE_ACCOUNT_KEY" \
    > pcf-pipelines/install-pcf/$IAAS_TYPE/terraform/gcp_service_account_key.json
