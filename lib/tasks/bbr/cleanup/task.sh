#!/bin/bash

source ~/scripts/iaas-func.sh
iaas::initialize

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

source backup-session/env*.sh

if [[ -d restore-timestamp ]]; then
    metadata_file=restore-timestamp/metadata
elif [[ $backup_mounted == yes ]]; then
    mkdir -p $backup_path/
    metadata_file=$backup_path/metadata
else
    echo "ERROR! Unable determine destination for backup metadata."
    exit 1
fi

grep -q "^RESTORE_TIMESTAMP=" $metadata_file && \
    sed -i "s|^RESTORE_TIMESTAMP=.*$|RESTORE_TIMESTAMP=$BACKUP_TIMESTAMP|" $metadata_file || \
    echo "RESTORE_TIMESTAMP=$BACKUP_TIMESTAMP" >> $metadata_file

[[ -n $BACKUP_AGE ]] || BACKUP_AGE=7
backup::cleanup "$BACKUP_AGE" "$BACKUP_TYPE" "$BACKUP_TARGET"

set +e +x
