#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/bosh-func.sh
iaas::initialize

[[ -z "$TRACE" ]] || set -x
set -e

if [[ -e job-session/env ]]; then
    source job-session/env
    bosh_client_creds
fi

bosh::login_client "$CA_CERT" "$BOSH_HOST" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"

DEPLOYMENTS=${DEPLOYMENTS:-$(bosh::deployment .*)}

bosh::deployment_action disable_resurrection $DEPLOYMENTS
bosh::deployment_action stop $DEPLOYMENTS
instance_ips=""
for d in $DEPLOYMENTS; do
    ips=$(bosh::get_job_instance_fields "$d" ".*" "4")
    instance_ips="$(echo $ips) $instance_ips"
done
iaas::start_stop_instances_by_ip "$IAAS" "$LABEL" stop $instance_ips

set +ex
