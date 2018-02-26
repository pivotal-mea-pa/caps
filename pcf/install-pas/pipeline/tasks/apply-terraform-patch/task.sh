#!/bin/bash
set -eu

cp -r pcf-pipelines-orig/* pcf-pipelines/

# Copy terraform templates that patch the pcf-piplines 
# templates and attaches PCF VPC it to the bootstrap VPC.
cp automation-pipelines/pcf/install-pas/pipeline/terraform/$IAAS_TYPE/* \
    pcf-pipelines/install-pcf/$IAAS_TYPE/terraform/
