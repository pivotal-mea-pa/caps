#!/bin/bash

source ~/scripts/iaas-func.sh
iaas::initialize

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

source backup-session/env*.sh

if [[ $backup_mounted == yes ]]; then
    mkdir -p $backup_path/
    metadata_file=$backup_path/metadata
    touch $metadata_file
else
    metadata_file=./metadata
fi

grep -q "^RESTORE_TIMESTAMP=" $metadata_file && \
    sed -i "s|^RESTORE_TIMESTAMP=.*$|RESTORE_TIMESTAMP=$BACKUP_TIMESTAMP|" $metadata_file || \
    echo "RESTORE_TIMESTAMP=$BACKUP_TIMESTAMP" >> $metadata_file

cp $metadata_file ./restore-timestamp

[[ -n $BACKUP_AGE ]] || BACKUP_AGE=7
backup::cleanup "$BACKUP_AGE" "$BACKUP_TYPE" "$BACKUP_TARGET"

set +e +x
