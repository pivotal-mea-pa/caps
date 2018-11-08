#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

[[ -n "$TRACE" ]] && set -x
set -eu

mv pks-release/pks-linux-amd64-* /usr/local/bin/pks
chmod +x /usr/local/bin/pks

mv pks-release/kubectl-linux-amd64-* /usr/local/bin/kubectl
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

pks login --skip-ssl-validation --api $PKS_API --username $PKS_USERNAME --password $PKS_PASSWORD

clusters='['
cluster_ids='{'
cluster_instances='{'

pks_clusters=$(pks clusters | awk '$1 != "Name" { print $1 }')
for c in $pks_clusters; do

    info=$(pks cluster $c)
    status=$(echo "$info" | awk -F':' '/Last Action State/{ print $2 }' | sed -e 's/^[[:space:]]*//')
    if [[ "$status" == "succeeded" ]]; then

        uuid=$(echo "$info" | awk '/UUID/{ print $ 2}')

        clusters="$clusters \"$c\","
        cluster_ids="$cluster_ids \"$c\"=\"$uuid\","
        cluster_instances="$cluster_instances \"$c\"=\""

        master_vms=$(bosh-cli -e $BOSH_HOST -d service-instance_$uuid vms | awk '/master\//{ print $3"/"$5 }')
        for vm in $master_vms; do
            cluster_instances="${cluster_instances}$vm,"
        done

        cluster_instances="$cluster_instances\","
    fi
done

export TF_VAR_clusters="$clusters ]"
export TF_VAR_cluster_ids="$cluster_ids }"
export TF_VAR_cluster_instances="$cluster_instances }"

terraform init \
    -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
    -backend-config="prefix=${GCP_RESOURCE_PREFIX}-k8s-clusters" \
    automation/lib/pipelines/pcf/install-and-upgrade/tasks/create-pks-loadbalancers/gcp/terraform

terraform apply \
    -auto-approve \
    automation/lib/pipelines/pcf/install-and-upgrade/tasks/create-pks-loadbalancers/gcp/terraform
