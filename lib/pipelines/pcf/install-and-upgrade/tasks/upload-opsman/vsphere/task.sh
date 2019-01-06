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
  set -e

  govc import.spec \
    $ova_file_path \
    | jq \
    --arg image_name "$name" \
    --arg network "$OPSMAN_VCENTER_NETWORK" \
    --arg opsman_ip "$OPSMAN_IP" \
    --arg opsman_netmask "$OPSMAN_NETMASK" \
    --arg opsman_gateway "$OPSMAN_GATEWAY" \
    --arg opsman_dns_servers "$OPSMAN_DNS_SERVERS" \
    --arg opsman_ntp_servers "$OPSMAN_NTP_SERVERS" \
    --arg opsman_ssh_password "$OPSMAN_SSH_PASSWORD" \
    --arg opsman_ssh_public_key "$OPSMAN_SSH_PUBLIC_KEY" \
    --arg opsman_hostname "$OPSMAN_HOSTNAME" \
    'del(.Deployment)
    | .PropertyMapping.ip0 = "$opsman_ip"
    | .PropertyMapping.netmask0 = "$opsman_netmask"
    | .PropertyMapping.gateway = "$opsman_gateway"
    | .PropertyMapping.DNS = "$opsman_dns_servers"
    | .PropertyMapping.ntp_servers = "$opsman_ntp_servers"
    | .PropertyMapping.admin_password = "$opsman_ssh_password"
    | .PropertyMapping.public_ssh_key = "$opsman_ssh_public_key"
    | .PropertyMapping.custom_hostname = "$opsman_hostname"
    | .Name = "$image_name"
    | .DiskProvisioning = "thin"
    | .NetworkMapping[].Network = "$network"
    | .PowerOn = false
    | .MarkAsTemplate = true' \
    > import-spec.json

  govc import.ova \
    -dc=${VCENTER_DATACENTER} \
    -ds=${OPSMAN_VCENTER_DATASTORE} \
    -folder=${template_path} \
    -options=import-spec.json \
    $ova_file_path 
else
  echo "Ops Manager template '$name' exists skipping upload."
fi
