#!/bin/bash

set -exu

download_file_path=${opsman-image-path}
tar xvzf $download_file_path

ova_file_path=$(find ./pivnet-product -name *.ova | sort | head -1)
if [[ -z $ova_file_path ]]; then
  echo "ERROR! Ops Manager OVA file not found in $(pwd)/pivnet-product."
  exit 1
fi

name=$(basename $download_file_path)
opsman_name_version=$(echo $name | sed "s|\(.*\)_.*\.tgz$|\1|")
opsman_name=$(echo $name | sed "s|\(.*\)_.*_.*\.tgz$|\1|")

vm_folder=/${vcenter_datacenter}/vm/${vcenter_vms_path}

set +e
govc ls $vm_folder | grep $opsman_name_version >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  set -e

  deployed_opsman=$(govc ls $vm_folder | grep 'ops-manager' | head -1)
  if [[ -n $deployed_opsman ]]; then
    govc vm.power -off $vm_folder/$deployed_opsman >/dev/null 2>&1
    govc vm.destroy $vm_folder/$deployed_opsman >/dev/null 2>&1
  fi

  vcenter_network='${vcenter_network}'
  opsman_ip='${opsman_ip}'
  opsman_netmask='${opsman_netmask}'
  opsman_gateway='${opsman_gateway}'
  opsman_dns_servers='${opsman_dns_servers}'
  opsman_ntp_servers='${opsman_ntp_servers}'
  opsman_ssh_password='${opsman_ssh_password}'
  opsman_ssh_public_key='${opsman_ssh_public_key}'
  opsman_hostname='${opsman_hostname}'

  govc import.spec \
    $ova_file_path \
    | jq \
    --arg image_name "$opsman_name_version" \
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
    | .PowerOn = false' \
    > import-spec.json

  # Import OVA and power the VM on so that 
  # the initial configuration is applied.
  govc import.ova \
    -dc=${vcenter_datacenter} \
    -ds=${vcenter_datastore} \
    -folder=$vm_folder \
	  -pool=${vcenter_resource_pool} \
    -options=import-spec.json \
    $ova_file_path 1>/dev/null

  # We need the attached disk to be independent-
  # persistent. However, it does not seem govc
  # provides the correct combination of options to
  # allow this. Using -link=true results in a child
  # disk of same size as given disk to be created
  # which is not the desired outcome. Based on
  # the code:
  #
  # https://github.com/vmware/govmomi/blob/master/govc/vm/disk/attach.go#L122
  #
  # the combination of options -link=false and
  # -persist=true should result in the disk mode
  # being "persistent" which does not seem to take
  # effect. Possibly the -mode option which will be
  # available in the next build of govc will enable
  # attaching external disk directly with disk mode
  # independent_persistent.
  govc vm.disk.attach \
    -dc=${vcenter_datacenter} \
    -ds=${vcenter_datastore} \
    -vm "$vm_folder/$opsman_name_version" \
    -link=false \
    -persist=true \
    -sharing=sharingNone \
    -disk ${opsman_data_disk_path}

  govc vm.power \
    -on "$vm_folder/$opsman_name_version"
fi
