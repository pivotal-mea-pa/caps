#!/bin/bash

[[ -n "$TRACE" ]] && set -x

source ~/scripts/bosh-func.sh
set -euo pipefail

bosh::set_bosh_cli

source automation/lib/scripts/utility/template-utils.sh

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

patches_path=automation/lib/pipelines/pcf/install-and-upgrade/patches
pipeline_path=automation/lib/pipelines/pcf/install-and-upgrade/pipeline/upgrade-buildpacks

env=$(echo $ENVIRONMENT | awk '{print toupper($0)}')
echo "\n*** Configuring buildpack upgrade pipeline for ${env} ***\n"

# Setup buildpack upgrade pipeline
cf_user=$(om --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  credentials -p cf -c .uaa.admin_credentials -f identity)
cf_password=$(om --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  credentials -p cf -c .uaa.admin_credentials -f password)

cf_api_uri=https://api.$SYSTEM_DOMAIN

$bosh interpolate -o $patches_path/upgrade-buildpacks-patch.yml \
  $pipeline_path/pipeline.yml > upgrade-buildpacks-pipeline.yml

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

fly -t default set-pipeline -n \
  -p ${env}_upgrade-buildpacks \
  -c upgrade-buildpacks-pipeline.yml \
  -v "pivnet_token=$PIVNET_TOKEN" \
  -v "cf_api_uri=$cf_api_uri" \
  -v "cf_user=$cf_user" \
  -v "cf_password=$cf_password" \
  -v "autos3_url=$AUTOS3_URL" \
  -v "autos3_access_key=$AUTOS3_ACCESS_KEY" \
  -v "autos3_secret_key=$AUTOS3_SECRET_KEY" >/dev/null
