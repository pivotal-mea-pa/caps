#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

source automation/lib/scripts/utility/template-utils.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Source terraform output variables if available
source_variables 'terraform-output/pcf-env-*.sh'

mv pks-clis/pks-linux-amd64-* /usr/local/bin/pks
chmod +x /usr/local/bin/pks

mv pks-clis/kubectl-linux-amd64-* /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

# Save service key to a json file as Terraform GCS 
# backend only accepts the credential from a file.
echo "$GCP_SERVICE_ACCOUNT_KEY" > $root/gcp_service_account_key.json

export GOOGLE_CREDENTIALS=$root/gcp_service_account_key.json
export GOOGLE_PROJECT=${GCP_PROJECT_ID}
export GOOGLE_REGION=${GCP_REGION}

# Retrieve bosh credentials from Ops Manager API and set BOSH envrionment

if [[ -n "$OPSMAN_USERNAME" ]]; then
    opsman::login $OPSMAN_HOST $OPSMAN_USERNAME $OPSMAN_PASSWORD ''
elif [[ -n "$OPSMAN_CLIENT_ID" ]]; then
    opsman::login_client $OPSMAN_HOST $OPSMAN_CLIENT_ID $OPSMAN_CLIENT_SECRET ''
else
    echo "ERROR! Pivotal Operations Manager credentials were not provided."
    exit 1
fi

export BOSH_HOST=$(opsman::get_director_ip)
export BOSH_CA_CERT=$(opsman::download_bosh_ca_cert)
export BOSH_CLIENT='ops_manager'
export BOSH_CLIENT_SECRET=$(opsman::get_director_client_secret ops_manager)

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

        master_vms=$(bosh-cli -e $BOSH_HOST -d service-instance_$uuid vms | awk '/master\//{ print $3"/"$5 }')
        for vm in $master_vms; do
            cluster_instances="${cluster_instances}$vm,"
        done

        cluster_instances="$cluster_instances\","
    done

    export TF_VAR_clusters="$clusters ]"
    export TF_VAR_cluster_ids="$cluster_ids }"
    export TF_VAR_cluster_instances="$cluster_instances }"
else
    set -e
    export TF_VAR_clusters="[]"
    export TF_VAR_cluster_ids="{}"
    export TF_VAR_cluster_instances="{}"
fi

terraform init \
    -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
    -backend-config="prefix=${GCP_RESOURCE_PREFIX}-k8s-clusters" \
    automation/lib/pipelines/pcf/install-and-upgrade/terraform/gcp/pks-loadbalancers

terraform apply \
    -auto-approve \
    -var "terraform_state_bucket=${TERRAFORM_STATE_BUCKET}" \
    -var "pcf_state_prefix=${GCP_RESOURCE_PREFIX}" \
    automation/lib/pipelines/pcf/install-and-upgrade/terraform/gcp/pks-loadbalancers
