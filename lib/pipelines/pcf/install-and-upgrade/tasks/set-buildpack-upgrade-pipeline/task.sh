#!/bin/bash

set -euo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

install_and_upgrade_patches_path=automation/lib/pipelines/pcf/install-and-upgrade/patches

env=$(echo $ENVIRONMENT | awk '{print toupper($0)}')
echo "\n*** Configuring buildpack upgrade pipeline for ${env} ***\n"

# Setup buildpack upgrade pipeline
om_cli="om --skip-ssl-validation
  --target 'https://${OPSMAN_HOST}'
  --client-id '${OPSMAN_CLIENT_ID}' \
  --client-secret '${OPSMAN_CLIENT_SECRET}' \
  --username '${OPSMAN_USERNAME}' \
  --password '${OPSMAN_PASSWORD}'"

cf_user=$($om_cli credentials -p cf -c .uaa.admin_credentials -f identity)
cf_password=$($om_cli credentials -p cf -c .uaa.admin_credentials -f password)

cf_api_uri=https://api.$system_domain

curl -L https://raw.githubusercontent.com/pivotal-cf/pcf-pipelines/master/upgrade-buildpacks/pipeline.yml \
  -o upgrade-buildpacks-pipeline-orig.yml

cat upgrade-buildpacks-pipeline-orig.yml \
    | yaml_patch -o $install_and_upgrade_patches_path/upgrade-buildpacks-patch.yml \
    > upgrade-buildpacks-pipeline.yml
    
fly -t default set-pipeline -n \
  -p ${env}_upgrade-buildpacks \
  -c upgrade-buildpacks-pipeline.yml \
  -l install-pcf-params.yml \
  -v "cf_api_uri=$cf_api_uri" \
  -v "cf_user=$cf_user" \
  -v "cf_password=$cf_password" \
  -v "autos3_url=$AUTOS3_URL" \
  -v "autos3_access_key=$AUTOS3_ACCESS_KEY" \
  -v "autos3_secret_key=$AUTOS3_SECRET_KEY" >/dev/null
