#!/bin/bash

set -euo pipefail

echo "$GOOGLE_CREDENTIALS_JSON" > .gcp-service-account.json
export GOOGLE_CREDENTIALS=$(pwd)/.gcp-service-account.json
gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS

# Create a local s3 bucket for pcf automation data
mc config host add auto $AUTOS3_URL $AUTOS3_ACCESS_KEY $AUTOS3_SECRET_KEY
[[ "$(mc ls auto/ | awk '/pcf\/$/{ print $5 }')" == "pcf/" ]] || \
  mc mb auto/pcf

TERRAFORM_PARAMS_PATH=automation/pcf/bootstrap/gcp/params

#
# Configure install PCF pipeline
#

INSTALL_AND_UPGRADE_PIPELINE_PATH=automation/pcf/install-and-upgrade/pipeline
INSTALL_AND_UPGRADE_PATCHES_PATH=automation/pcf/install-and-upgrade/patches

terraform init $TERRAFORM_PARAMS_PATH

terraform apply -auto-approve \
  -var "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -var "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -var "params_template_file=$INSTALL_AND_UPGRADE_PIPELINE_PATH/gcp/params.yml" \
  -var "params_file=install-pcf-params.yml" \
  $TERRAFORM_PARAMS_PATH >/dev/null

set -x

cp $INSTALL_AND_UPGRADE_PIPELINE_PATH/gcp/${PCF_PAS_RUNTIME_TYPE}-pipeline.yml install-pcf-pipeline0.yml
i=0 && j=1
for p in $(echo -e "$PRODUCTS"); do 
  product_name=${p%:*}
  slug_and_version=${p#*:}
  product_slug=${slug_and_version%/*}
  product_version=${slug_and_version#*/}

  eval "echo \"$(cat $INSTALL_AND_UPGRADE_PATCHES_PATH/install-tile-patch.yml)\"" \
    > ${product_name}-patch.yml

  cat install-pcf-pipeline$i.yml \
    | yaml_patch -o ${product_name}-patch.yml \
    > install-pcf-pipeline$j.yml

  i=$(($i+1)) && j=$(($j+1))
done

set +x

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

fly -t default set-pipeline -n \
  -p PCF_install-and-upgrade \
  -c install-pcf-pipeline$i.yml \
  -l install-pcf-params.yml \
  -v "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -v "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -v "autos3_url=$AUTOS3_URL" \
  -v "autos3_access_key=$AUTOS3_ACCESS_KEY" \
  -v "autos3_secret_key=$AUTOS3_SECRET_KEY" >/dev/null

# Unpause the pipeline. The pipeline jobs will rerun in 
# an idempotent manner if a prior installation is found.
fly -t default unpause-pipeline -p PCF_install-and-upgrade

set +e

bootstrap_state_job_status=$(fly -t default watch \
  -j PCF_install-and-upgrade/bootstrap-terraform-state 2>&1)

if [[ "$bootstrap_state_job_status" == "error: job has no builds" ]]; then

  # Bootstrap the Terraform state if it is 
  # empty and wait until the job finishes
  fly -t default trigger-job -j PCF_install-and-upgrade/bootstrap-terraform-state
  fly -t default watch -j PCF_install-and-upgrade/bootstrap-terraform-state

  # Start the install by starting the upload-opsman-image job 
  fly -t default trigger-job -j PCF_install-and-upgrade/upload-opsman-image
fi

# Wait until the Pivotal Application Service
# tile has been successfully deployed.
b=1
while true; do
  r=$(fly -t default watch -j PCF_install-and-upgrade/deploy-${PCF_PAS_RUNTIME_TYPE} -b $b 2>&1)
  [[ $? -eq 0 ]] && break

  s=$(echo "$r" | tail -1)
  if [[ "$s" == "failed" ]]; then
    echo -e "\n*** Job PCF_install-and-upgrade/deploy-${PCF_PAS_RUNTIME_TYPE} FAILED! ***\n"
    echo -e "$r\n"
    b=$(($b+1))
  fi
  echo "Waiting for job PCF_install-and-upgrade/deploy-${PCF_PAS_RUNTIME_TYPE} build $b to complete..."
  sleep 5
done

set -e

# Setup buildpack upgrade pipeline
om_cli="om --skip-ssl-validation 
  --target https://${OPSMAN_DOMAIN_OR_IP_ADDRESS} 
  --username ${OPSMAN_USERNAME}
  --password ${OPSMAN_PASSWORD}"

$om_cli curl -p /api/installation_settings > installation_settings.json
cf_sys_domain=$(cat installation_settings.json \
    | jq -r '.products[] | select(.installation_name | match("cf-.*")) | .jobs[] | select(.installation_name == "cloud_controller") | .properties[] | select(.identifier == "system_domain") | .value')
cf_apps_domain=$(cat installation_settings.json \
    | jq -r '.products[] | select(.installation_name | match("cf-.*")) | .jobs[] | select(.installation_name == "cloud_controller") | .properties[] | select(.identifier == "apps_domain") | .value')

cf_user=$($om_cli credentials -p cf -c .uaa.admin_credentials -f identity)
cf_password=$($om_cli credentials -p cf -c .uaa.admin_credentials -f password)

cf_api_uri=https://api.$cf_sys_domain

curl -L https://raw.githubusercontent.com/pivotal-cf/pcf-pipelines/master/upgrade-buildpacks/pipeline.yml \
  -o upgrade-buildpacks-pipeline-orig.yml

cat upgrade-buildpacks-pipeline-orig.yml \
    | yaml_patch -o $INSTALL_AND_UPGRADE_PATCHES_PATH/upgrade-buildpacks-patch.yml \
    > upgrade-buildpacks-pipeline.yml
    
fly -t default set-pipeline -n \
  -p PCF_upgrade-buildpacks \
  -c upgrade-buildpacks-pipeline.yml \
  -l install-pcf-params.yml \
  -v "cf_api_uri=$cf_api_uri" \
  -v "cf_user=$cf_user" \
  -v "cf_password=$cf_password" \
  -v "autos3_url=$AUTOS3_URL" \
  -v "autos3_access_key=$AUTOS3_ACCESS_KEY" \
  -v "autos3_secret_key=$AUTOS3_SECRET_KEY" >/dev/null

fly -t default unpause-pipeline -p PCF_upgrade-buildpacks

# Setup backup and restore pipeline

BACKUP_AND_RESTORE_PIPELINE_PATH=automation/pcf/backup-and-restore/pipeline

rm -fr .terraform/
rm terraform.tfstate

terraform init $TERRAFORM_PARAMS_PATH

terraform apply -auto-approve \
  -var "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -var "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -var "params_template_file=$BACKUP_AND_RESTORE_PIPELINE_PATH/gcp/params.yml" \
  -var "params_file=backup-and-restore-params.yml" \
  $TERRAFORM_PARAMS_PATH >/dev/null

fly -t default set-pipeline -n \
  -p PCF_backup-and-restore \
  -c $BACKUP_AND_RESTORE_PIPELINE_PATH/gcp/pipeline.yml \
  -l backup-and-restore-params.yml \
  -v "autos3_url=$AUTOS3_URL" \
  -v "autos3_access_key=$AUTOS3_ACCESS_KEY" \
  -v "autos3_secret_key=$AUTOS3_SECRET_KEY" >/dev/null

fly -t default unpause-pipeline -p PCF_backup-and-restore

# Setup start and stop pipeline

START_AND_STOP_PIPELINE_PATH=automation/pcf/stop-and-start/pipeline
START_AND_STOP_PATCHES_PATH=automation/pcf/stop-and-start/patches

rm -fr .terraform/
rm terraform.tfstate

terraform init $TERRAFORM_PARAMS_PATH

terraform apply -auto-approve \
  -var "bootstrap_state_bucket=$BOOTSTRAP_STATE_BUCKET" \
  -var "bootstrap_state_prefix=$BOOTSTRAP_STATE_PREFIX" \
  -var "params_template_file=$START_AND_STOP_PIPELINE_PATH/gcp/params.yml" \
  -var "params_file=start-and-stop-params.yml" \
  $TERRAFORM_PARAMS_PATH >/dev/null

if [[ $SET_START_STOP_SCHEDULE == true ]]; then
  cat $START_AND_STOP_PIPELINE_PATH/gcp/pipeline.yml \
    | yaml_patch -o $START_AND_STOP_PATCHES_PATH/start-stop-schedule.yml > start-and-stop-pipeline.yml
else
  cp $START_AND_STOP_PIPELINE_PATH/gcp/pipeline.yml start-and-stop-pipeline.yml
fi

fly -t default set-pipeline -n \
  -p PCF_start-and-stop \
  -c start-and-stop-pipeline.yml \
  -l start-and-stop-params.yml \
  -v "autos3_url=$AUTOS3_URL" \
  -v "autos3_access_key=$AUTOS3_ACCESS_KEY" \
  -v "autos3_secret_key=$AUTOS3_SECRET_KEY" >/dev/null

fly -t default unpause-pipeline -p PCF_start-and-stop
