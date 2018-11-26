#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

mv pks-clis/pks-linux-amd64-* /usr/local/bin/pks
chmod +x /usr/local/bin/pks

mv pks-clis/kubectl-linux-amd64-* /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

# Retrieve bosh credentials from Ops Manager API and set BOSH envrionment

if [[ -n "$OPSMAN_USERNAME" ]]; then
  opsman::login $OPSMAN_HOST $OPSMAN_USERNAME $OPSMAN_PASSWORD ''
elif [[ -n "$OPSMAN_CLIENT_ID" ]]; then
  opsman::login_client $OPSMAN_HOST $OPSMAN_CLIENT_ID $OPSMAN_CLIENT_SECRET ''
else
  echo "ERROR! Pivotal Operations Manager credentials were not provided."
  exit 1
fi

export BOSH_ENVIRONMENT=$(opsman::get_director_ip)
export BOSH_CA_CERT=$(opsman::download_bosh_ca_cert)
export BOSH_CLIENT='ops_manager'
export BOSH_CLIENT_SECRET=$(opsman::get_director_client_secret ops_manager)

bosh::login_client "$BOSH_CA_CERT" "$BOSH_ENVIRONMENT" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"

# Retrive PKS cluster details into variables that can 
# be passed to IAAS specific terraform templates

set +e
pks login --skip-ssl-validation --api $PKS_URL --username $PKS_ADMIN_USERNAME --password $PKS_ADMIN_PASSWORD
if [[ $? -eq 0 ]]; then
  set -e
  
  clusters='['
  cluster_ids='{'
  cluster_instances='{'

  pks_clusters=$(pks clusters | awk '$1 != "Name" { print $1 }')
  for c in $pks_clusters; do

    info=$(pks cluster $c)
    uuid=$(echo "$info" | awk '/UUID/{ print $ 2}')

    clusters="$clusters \"$c\","
    cluster_ids="$cluster_ids \"$c\"=\"$uuid\","
    cluster_instances="$cluster_instances \"$c\"=\""

    master_vms=$($bosh -d service-instance_$uuid vms | awk '/master\//{ print $3"/"$5 }')
    for vm in $master_vms; do
      cluster_instances="${cluster_instances}$vm,"
    done

    cluster_instances="$cluster_instances\","
  done

  export TF_VAR_clusters="${clusters:0:-1} ]"
  export TF_VAR_cluster_ids="${cluster_ids:0:-1} }"
  export TF_VAR_cluster_instances="${cluster_instances:0:-1} }"
else
  set -e
  export TF_VAR_clusters="[]"
  export TF_VAR_cluster_ids="{}"
  export TF_VAR_cluster_instances="{}"
fi
exit 0
# Run IAAS specific cluster configuration
if [[ -e automation/lib/pipelines/pcf/install-and-upgrade/tasks/pks-cluster-config/${IAAS}/task.sh ]]; then
  automation/lib/pipelines/pcf/install-and-upgrade/tasks/pks-cluster-config/${IAAS}/task.sh 
fi
