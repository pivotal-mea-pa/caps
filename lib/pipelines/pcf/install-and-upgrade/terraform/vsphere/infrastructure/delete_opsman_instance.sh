#!/bin/bash

set -exu

vm_folder=/${vcenter_datacenter}/vm/${vcenter_vms_path}

deployed_opsman=$(govc ls $vm_folder | grep 'ops-manager' | head -1)
if [[ -n $deployed_opsman ]]; then
  
  set +e
  govc vm.power -off $vm_folder/$deployed_opsman
  
  # Ensure attached non-root disk does not get deleted.
  # It seems like the disk mode defaulting to "dependent"
  # causes is to be deleted when vm is deleted.
  govc device.remove -vm $vm_folder/$deployed_opsman --keep disk-1000-1

  set -e
  govc vm.destroy $vm_folder/$deployed_opsman
fi
