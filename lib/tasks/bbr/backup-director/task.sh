#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/bosh-func.sh
iaas::initialize

if [[ -n "$TRACE" ]]; then
    set -x
    debug_bbr="--debug"
fi
set -euo pipefail

source job-session/env*.sh

echo "Backing up Bosh Director via BBR utility..."

echo "$BBR_SSH_KEY" > bbr-ssh-key.pem
chmod 0600 bbr-ssh-key.pem

set +e

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    -i bbr-ssh-key.pem bbr@$BOSH_HOST -- "sudo -S rm -fr /var/vcap/store/bbr-backup"

if [[ $? -ne 0 ]]; then
    echo -e "\nUnable to SSH into bosh instance and clean up the BBR backup" 
    echo -e "folder which may have been left behind by past failed backups.\n"
    echo -e "Continuing as normal..."
fi

set -e

backup_dir=$backup_path/$BACKUP_TIMESTAMP/director
mkdir -p $backup_dir

pushd $backup_dir

bbr director $debug_bbr \
    --host "$BOSH_HOST" \
    --username bbr \
    --private-key-path <(echo "$BBR_SSH_KEY") \
    backup

popd

backup::upload "$BACKUP_TYPE" "$BACKUP_TARGET" "$KEEP_BACKUP"

set +ex