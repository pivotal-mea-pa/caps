#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
iaas::initialize

[[ -n "$TRACE" ]] && set -x
set -e

if [[ -n "$OPSMAN_SSH_PASSWD" ]]; then
    ssh_pass="sshpass -p$OPSMAN_SSH_PASSWD"
fi

source backup-timestamp/metadata
source job-session/env

opsman_backup_path=$(pwd)/$backup_path/$BACKUP_TIMESTAMP/opsman
mkdir -p $opsman_backup_path

installation_zip=$opsman_backup_path/installation.zip

curl -s -k "$opsman_url/api/v0/installation_asset_collection" \
  -H "Authorization: Bearer $opsman_token" \
  -X GET -o $installation_zip &
export_pid=$!

opsman::get_installation > $(dirname $installation_zip)/installation.json

wait $export_pid

set +e
file $installation_zip | grep 'ASCII text' >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    cat $installation_zip
    exit 1
fi
set -e

backup::upload "$BACKUP_TYPE" "$BACKUP_TARGET" "$KEEP_BACKUP"
