#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/opsman-func.sh
iaas::initialize

[[ -n "$TRACE" ]] && set -x
set -e

# Authenticate with Ops Manager API

if [[ -n "$OPSMAN_USER" ]]; then
    opsman::login $OPSMAN_HOST $OPSMAN_USER $OPSMAN_PASSWD $OPSMAN_PASS_PHRASE
elif [[ -n "$PCFOPS_CLIENT" ]]; then
    opsman::login_client $OPSMAN_HOST $PCFOPS_CLIENT $PCFOPS_SECRET $OPSMAN_PASS_PHRASE
else
    echo "ERROR! Pivotal Operations Manager credentials were not provided."
    exit 1
fi

# Create script to source environment for downstream jobs/tasks

cat <<EOF > job-session/env
#!/bin/bash

source ~/scripts/opsman-func.sh

opsman_url='$opsman_url'
opsman_token='$opsman_token'

export BOSH_HOST=''\$(opsman::get_director_ip)''
if [[ -z "\$BOSH_HOST" ]]; then
    echo "ERROR! Unable to retrieve BOSH host address. You may need to re-run prepare task to refresh the ops manager token."
    exit 1
fi

export CA_CERT='$(opsman::download_bosh_ca_cert)'
export BBR_SSH_KEY=''\$(opsman::get_bbr_ssh_key)''

function bosh_user_creds() { 
    export BOSH_USER=''\$(opsman::get_director_user)''
    export BOSH_PASSWD=''\$(opsman::get_director_password)''
}

function bosh_vm_creds() { 
    export BOSH_VM_USER=''\$(opsman::get_director_vm_user)''
    export BOSH_VM_PASSWD=''\$(opsman::get_director_vm_password)''
}

function bosh_client_creds() { 
    export BOSH_ENVIRONMENT=\$BOSH_HOST
    export BOSH_CA_CERT=\$CA_CERT
    export BOSH_CLIENT='ops_manager'
    export BOSH_CLIENT_SECRET=''\$(opsman::get_director_client_secret ops_manager)''
}

#
# Usage: bosh_vm_vcap_password <PRODUCT_GUID> <VM_NAME_PATTERN>
#
function bosh_vm_vcap_password() { 
    opsman::get_product_vm_credential "\$1" "\$2"
}
EOF

set +e +x
