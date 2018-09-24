#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/bosh-func.sh
iaas::initialize

[[ -z "$TRACE" ]] || set -x
set -eo pipefail

if [[ -e job-session/env ]]; then
    source job-session/env
    bosh_client_creds
fi

bosh::login_client "$CA_CERT" "$BOSH_HOST" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"
bosh::deployment_action run_smoke_tests_errand $DEPLOYMENTS

set +ex
