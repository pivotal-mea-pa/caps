#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/opsman-func.sh
iaas::initialize

[[ -n "$TRACE" ]] && set -x
set -e

if [[ -d backup-metadata ]]; then
    cp -r backup-metadata/* backup-timestamp/
elif [[ $backup_mounted == yes ]]; then
    if [[ -e $backup_path/metadata ]]; then
        cp $backup_path/metadata backup-timestamp/
    else
        touch backup-timestamp/metadata
    fi
else
    echo "ERROR! Unable to locate backup metadata."
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d%H%M%S)
grep -q "^BACKUP_TIMESTAMP=" backup-timestamp/metadata && \
    sed -i "s|^BACKUP_TIMESTAMP=.*$|BACKUP_TIMESTAMP=$TIMESTAMP|" backup-timestamp/metadata || \
    echo "BACKUP_TIMESTAMP=$TIMESTAMP" >> backup-timestamp/metadata

# Wait for any current apply jobs to finish

if [[ -n "$OPSMAN_USERNAME" ]]; then
    opsman::login "$OPSMAN_HOST" "$OPSMAN_USERNAME" "$OPSMAN_PASSWORD" "$OPSMAN_DECRYPTION_KEY"
elif [[ -n "$OPSMAN_CLIENT_ID" ]]; then
    opsman::login_client "$OPSMAN_HOST" "$OPSMAN_CLIENT_ID" "$OPSMAN_CLIENT_SECRET" "$OPSMAN_DECRYPTION_KEY"
else
    echo "ERROR! Pivotal Operations Manager credentials were not provided."
    exit 1
fi
opsman::wait_for_last_apply_to_finish
opsman::kill_active_sessions

# Clean up Ops Manager /tmp folder to free up space for export and restart the service

if [[ -n "$CLEAN_UP_OPSMAN" ]]; then

    [[ -z "$OPSMAN_SSH_PASSWD" ]] || ssh_pass="sshpass -p$OPSMAN_SSH_PASSWD"
    $ssh_pass ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $OPSMAN_SSH_USER@$OPSMAN_HOST -- \
        "echo $OPSMAN_SSH_PASSWD | sudo -S sh -c 'service tempest-web stop; rm -fr /tmp/*; service tempest-web start'"
fi

if [[ -n "$OPSMAN_USERNAME" ]]; then
    opsman::login "$OPSMAN_HOST" "$OPSMAN_USERNAME" "$OPSMAN_PASSWORD" "$OPSMAN_DECRYPTION_KEY"
elif [[ -n "$OPSMAN_CLIENT_ID" ]]; then
    opsman::login_client "$OPSMAN_HOST" "$OPSMAN_CLIENT_ID" "$OPSMAN_CLIENT_SECRET" "$OPSMAN_DECRYPTION_KEY"
fi

# Create script to source environment for downstream jobs/tasks

cat <<EOF > job-session/env
#!/bin/bash

export BACKUP_TIMESTAMP=$TIMESTAMP

source ~/scripts/opsman-func.sh

opsman_url='$opsman_url'
opsman_token='$opsman_token'

export BOSH_HOST=''\$(opsman::get_installation | jq -r \
    '.products[] | select(.installation_name == "p-bosh") | .director_configuration.allocated_director_ips[0]')''

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
    export BOSH_CLIENT='ops_manager'
    export BOSH_CLIENT_SECRET=''\$(opsman::get_director_client_secret ops_manager)''
}

function bosh_vm_vcap_password() { 
    opsman::get_product_vm_credential "\$1" "\$2"
}

function mysql_creds() { 
    export ERT_MYSQL_USER=''\$(opsman::get_product_credential cf- mysql_admin_credentials | jq -r .credential.value.identity)''
    export ERT_MYSQL_PASSWORD=''\$(opsman::get_product_credential cf- mysql_admin_credentials | jq -r .credential.value.password)''
    export MYSQL_USER=''\$(opsman::get_product_credential p-mysql- mysql_admin_password | jq -r .credential.value.identity)''
    export MYSQL_PASSWORD=''\$(opsman::get_product_credential p-mysql- mysql_admin_password | jq -r .credential.value.password)''
}

function rmq_creds() { 
    export RMQ_ADMIN_USER=''\$(opsman::get_product_credential p-rabbitmq- server_admin_credentials | jq -r .credential.value.identity)''
    export RMQ_ADMIN_PASSWORD=''\$(opsman::get_product_credential p-rabbitmq- server_admin_credentials | jq -r .credential.value.password)''
}
EOF

set +e +x
