#!/bin/bash

source ~/scripts/opsman-func.sh

[[ -n "$TRACE" ]] && set -x
set -e

source job-session/env

tile=$1
service=$2
scale=$3

om -k -t https://$OPSMAN_HOST -c $PCFOPS_CLIENT -s $PCFOPS_SECRET \
    configure-product -n ${tile%-*} -pr '{"'$service'": {"instances": '$scale'}}'
