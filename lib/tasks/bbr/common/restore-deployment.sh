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
source job-session/env
bosh_client_creds

bosh::login_client "$CA_CERT" "$BOSH_HOST" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"

deployment=$1
archive_dest_name=$2

backup::download "$BACKUP_TYPE" "$BACKUP_TARGET" "$RESTORE_TIMESTAMP" $archive_dest_name

deployment_name=$(bosh::deployment $deployment)

echo "Restoring Bosh deployment '$deployment_name' via BBR utility..."

bbr deployment $debug_bbr \
    --target "$BOSH_HOST" \
    --username "${BOSH_CLIENT}" \
    --password "${BOSH_CLIENT_SECRET}" \
    --deployment "$deployment_name" \
    --ca-cert <(echo "$CA_CERT") \
    restore \
    --artifact-path $(ls -d -1 $backup_path/$archive_dest_name/** | head -1)
