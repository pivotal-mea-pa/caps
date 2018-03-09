#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/bosh-func.sh
iaas::initialize

if [[ -n "$TRACE" ]]; then
    set -x
    debug_bbr="--debug"
fi
set -e

source job-session/env
bosh_client_creds

backup::download "$BACKUP_TYPE" "$BACKUP_TARGET" "$RESTORE_TIMESTAMP" director

echo "Restoring Bosh Director via BBR utility..."

bbr director $debug_bbr \
    --host "$BOSH_HOST" \
    --username bbr \
    --private-key-path <(echo "$BBR_SSH_KEY") \
    restore \
    --artifact-path $(ls -d -1 $backup_path/director/** | head -1)

# Remove Stale Cloud IDs for All Deployments
bosh::login_client "$CA_CERT" "$BOSH_HOST" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"

for d in $(bosh::deployment .*); do 
    bosh-cli -e default -d $d -n cck \
        --resolution delete_disk_reference \
        --resolution delete_vm_reference
done
