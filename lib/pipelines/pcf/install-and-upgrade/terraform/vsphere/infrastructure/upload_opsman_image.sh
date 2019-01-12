#!/bin/bash

set -exu

vcenter_datacenter=$1
vcenter_vms_path=$2
vcenter_cluster=$3
vcenter_network=$4
vcenter_datastore=$5

opsman_ip=$6
opsman_netmask=$7
opsman_gateway=$8
opsman_dns_servers=$9
opsman_ntp_servers=$10
opsman_ssh_password=$11
opsman_ssh_public_key=$12
opsman_hostname=$13

opsman_data_disk_path=$14

download_file_path=$(find ./pivnet-download -name *.tgz | sort | head -1)
tar xvzf $download_file_path

ova_file_path=$(find ./pivnet-product -name *.ova | sort | head -1)

name=$(basename $download_file_path)
opsman_name_version=${name%_*}
opsman_name=${name%%_*}

vm_folder=/${vcenter_datacenter}/vm/${vcenter_vms_path}

set +e
govc ls ${vm_folder} | grep ${opsman_name_version} >/dev/null 2>&1
if [[ $? -ne 0 ]]; then

  deployed_opsman=$(govc ls ${vm_folder} | grep ${opsman_name} | head -1)
  if [[ -n $deployed_opsman ]]; then
	govc vm.power -off $vm_folder/$name
    govc vm.destroy $vm_folder/$name
  fi
  
  set -e

  govc import.spec \
    $ova_file_path \
    | jq \
    --arg image_name "$name" \
    --arg network "$vcenter_network" \
    --arg opsman_ip "$opsman_ip" \
    --arg opsman_netmask "$opsman_netmask" \
    --arg opsman_gateway "$opsman_gateway" \
    --arg opsman_dns_servers "$opsman_dns_servers" \
    --arg opsman_ntp_servers "$opsman_ntp_servers" \
    --arg opsman_ssh_password "$opsman_ssh_password" \
    --arg opsman_ssh_public_key "$opsman_ssh_public_key" \
    --arg opsman_hostname "$opsman_hostname" \
    'del(.Deployment)
    | (.PropertyMapping[] | select(.Key == "ip0")).Value = $opsman_ip
    | (.PropertyMapping[] | select(.Key == "netmask0")).Value = $opsman_netmask
    | (.PropertyMapping[] | select(.Key == "gateway")).Value = $opsman_gateway
    | (.PropertyMapping[] | select(.Key == "DNS")).Value = $opsman_dns_servers
    | (.PropertyMapping[] | select(.Key == "ntp_servers")).Value = $opsman_ntp_servers
    | (.PropertyMapping[] | select(.Key == "admin_password")).Value = $opsman_ssh_password
    | (.PropertyMapping[] | select(.Key == "public_ssh_key")).Value = $opsman_ssh_public_key
    | (.PropertyMapping[] | select(.Key == "custom_hostname")).Value = $opsman_hostname
    | .Name = $image_name
    | .DiskProvisioning = "thin"
    | .NetworkMapping[].Network = $network
    | .PowerOn = true
    | .WaitForIP = true' \
    > import-spec.json

  # Import OVA and power the VM on so that 
  # the initial configuration is applied.
  echo govc import.ova \
    -dc=${vcenter_datacenter} \
    -ds=${vcenter_datastore} \
    -folder=${vm_folder} \
	-pool=/${vcenter_datacenter}/host/${vcenter_cluster}/Resources \
    -options=import-spec.json \
    $ova_file_path > xxx
else
  echo "Ops Manager template '$name' exists skipping upload."
fi

echo "{}"