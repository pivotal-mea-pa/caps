#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/bosh-func.sh
iaas::initialize

if [[ -n "$TRACE" ]]; then
    set -x
    debug_bbr="--debug"
fi
set -e

source backup-timestamp/metadata
source job-session/env
bosh_client_creds

bosh::login_client "$CA_CERT" "$BOSH_HOST" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"

deployment=$1
archive_dest_name=$2

deployment_name=$(bosh::deployment $deployment)

bosh::ssh $deployment_name ".*" "[[ ! -e /var/vcap/store ]] || rm -fr /var/vcap/store/bbr-backup"

echo "Backing up Bosh deployment '$deployment_name' via BBR utility..."

backup_dir=$backup_path/$BACKUP_TIMESTAMP/$archive_dest_name
mkdir -p $backup_dir

pushd $backup_dir

bbr deployment $debug_bbr \
    --target "$BOSH_HOST" \
    --username "${BOSH_CLIENT}" \
    --password "${BOSH_CLIENT_SECRET}" \
    --deployment "$deployment_name" \
    --ca-cert <(echo "$CA_CERT") \
    backup --with-manifest

popd

backup::upload "$BACKUP_TYPE" "$BACKUP_TARGET" "$KEEP_BACKUP"

set +ex