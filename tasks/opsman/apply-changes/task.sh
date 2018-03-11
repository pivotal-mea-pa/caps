#!/bin/bash

source ~/scripts/opsman-func.sh

[[ -n "$TRACE" ]] && set -x
set -e

source job-session/env

if [[ "$1" == "no_errands" ]]; then
    opsman::apply_changes
else
    om -k -t https://$OPSMAN_HOST -c $PCFOPS_CLIENT -s $PCFOPS_SECRET apply-changes -i
fi
