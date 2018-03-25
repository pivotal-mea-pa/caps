#!/bin/bash

[[ -n "${attached_device_name}" ]] || exit 0

# Mount and format the data volume if available and unformatted

i=12
while [ $i -gt 0 ]; do
  device="/dev/$(lsblk | grep "$(basename ${attached_device_name})" | head -1 | cut -d" " -f1)"

  if [[ -n $device ]] && [[ $device == ${attached_device_name} ]]; then
    break
  fi
  echo "Waiting for data volume to be attached..."
  sleep 5
  i=$(($i-1))
done

if [[ -n $device ]]; then

  # Un-mount data volume
  sudo umount ${mount_directory} > /dev/null 2>&1
  sudo su - -c "sed -i 's|^/dev/${attached_device_name}\s*${mount_directory}\s*.*$||' /etc/fstab"
  
  sudo tune2fs -l $device > /dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    # Format new volume
    sudo mkfs.ext4 $device
  fi

  # Mount data volume
  sudo mkdir -p ${mount_directory}
  sudo su - -c "echo -e \"\\n$device\\t${mount_directory}\\text4\\tdefaults\\t0 1\" >> /etc/fstab"
  sudo mount -a

  [[ ${world_readable} == true ]] && sudo chmod a+rwx ${mount_directory}
else
  echo "WARNING! Timed out waiting for data volume. Proceeding as a new install."
fi
