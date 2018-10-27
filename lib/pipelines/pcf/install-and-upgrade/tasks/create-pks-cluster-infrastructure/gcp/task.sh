#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

[[ -n "$TRACE" ]] && set -x
set -eu

# Retrieve bosh credentials from Ops Manager API and set BOSH envrionment

if [[ -n "$OPSMAN_USERNAME" ]]; then
    opsman::login $OPSMAN_HOST $OPSMAN_USERNAME $OPSMAN_PASSWORD $OPSMAN_DECRYPTION_KEY
elif [[ -n "$OPSMAN_CLIENT_ID" ]]; then
    opsman::login_client $OPSMAN_HOST $OPSMAN_CLIENT_ID $OPSMAN_CLIENT_SECRET $OPSMAN_DECRYPTION_KEY
else
    echo "ERROR! Pivotal Operations Manager credentials were not provided."
    exit 1
fi

export BOSH_HOST==$(opsman::get_director_ip())
export BOSH_CA_CERT=$(opsman::download_bosh_ca_cert)
export BOSH_CLIENT='ops_manager'
export BOSH_CLIENT_SECRET=$(opsman::get_director_client_secret ops_manager)

sleep 1800
