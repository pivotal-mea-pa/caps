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

instance_ips=""
for d in $DEPLOYMENTS; do
    ips=$(bosh::get_job_instance_fields "$d" ".*" "4")
    instance_ips="$(echo $ips) $instance_ips"
done
iaas::start_stop_instances_by_ip "$IAAS" "$LABEL" start $instance_ips

# Ensure instances of all deployments to be started have 
# a "stopped" state before starting the deployment via Bosh

TIMEOUT=${TIMEOUT:-120}

i=0
while [[ $i -lt $TIMEOUT ]]; do

    j=0
    for d in $DEPLOYMENTS; do
    
        no_vms_not_in_stopped_state=$(bosh::vms_json $(bosh::deployment $d) \
            | jq -r '.[] | select(.process_state != "stopped") | .vm_cid' | wc -l)

        j=$(($j+$no_vms_not_in_stopped_state))
    done
    [[ $j -gt 0 ]] || break

    echo "Waiting for vms to reach stopped state..."
    sleep 5

    i=$(($i+1))
done
if [[ $i == 60 ]]; then
    echo "ERROR! Some instances did not reach a stopped state after they were booted."
    for d in $DEPLOYMENTS; do
        deployment=$(bosh::deployment $d)
        echo -e "\nDeployment $deployment"
        bosh::vms $deployment
    done
    exit 1
fi

# Clear consul caches
for d in $DEPLOYMENTS; do
    bosh::ssh $d ".*" "[[ ! -e /var/vcap/data/consul_agent/services ]] || rm -fr /var/vcap/data/consul_agent/services/*"
done

bosh::deployment_action start $DEPLOYMENTS
bosh::deployment_action enable_resurrection $DEPLOYMENTS

set +ex
