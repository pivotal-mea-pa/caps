#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

download_file_path=$(find ./pivnet-download -name *.tgz | sort | head -1)
tar xvzf $download_file_path

name=$(basename $download_file_path)
name=${name%_*}

template_path=/${VCENTER_DATACENTER}/vm/${VCENTER_TEMPLATES_PATH}

ova_file_path=$(find ./pivnet-product -name *.ova | sort | head -1)

set +e
govc ls ${template_path} | grep ${name} >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  govc folder.create "${template_path}" >/dev/null 2>&1

  govc import.spec \
    $ova_file_path \
    | jq \
    --arg image_name "$name" \
    --arg network "$OPSMAN_VCENTER_NETWORK" \
    'del(.Deployment) | del(.PropertyMapping)
    | .Name = $image_name
    | .DiskProvisioning = "thin"
    | .NetworkMapping[].Network = $network
    | .PowerOn = false
    | .MarkAsTemplate = true' \
    > import-spec.json

  govc import.ova \
    -dc=${VCENTER_DATACENTER} \
    -ds=${OPSMAN_VCENTER_DATASTORE} \
    -folder=${template_path} \
    -options=import-spec.json \
    $ova_file_path 
fi
set -e

