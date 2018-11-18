#!/bin/bash

source ~/scripts/iaas-func.sh
iaas::initialize

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

source backup-session/env*.sh

grep -q "^RESTORE_TIMESTAMP=" backup-timestamp/metadata && \
    sed -i "s|^RESTORE_TIMESTAMP=.*$|RESTORE_TIMESTAMP=$BACKUP_TIMESTAMP|" backup-timestamp/metadata || \
    echo "RESTORE_TIMESTAMP=$BACKUP_TIMESTAMP" >> backup-timestamp/metadata

if [[ -d restore-timestamp ]]; then
    cp -r backup-timestamp/* restore-timestamp/
elif [[ $backup_mounted == yes ]]; then
    mkdir -p $backup_path/
    cp -f backup-timestamp/metadata $backup_path/
else
    echo "ERROR! Unable determine destination for backup metadata."
    exit 1
fi

[[ -n $BACKUP_AGE ]] || BACKUP_AGE=7
backup::cleanup "$BACKUP_AGE" "$BACKUP_TYPE" "$BACKUP_TARGET"

set +e +x
