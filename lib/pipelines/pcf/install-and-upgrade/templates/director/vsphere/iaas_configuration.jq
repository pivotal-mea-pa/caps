#
# jq -n \
#   --arg deployment_prefix "" \
#   --arg vsphere_server "" \
#   --arg vsphere_user "" \
#   --arg vsphere_password "" \
#   --arg vcenter_datacenter "" \
#   --arg disk_type "thin" \
#   --arg vcenter_ephemeral_datastores "" \
#   --arg vcenter_persistant_datastores "" \
#   --arg vcenter_templates_path "pcf_templates" \
#   --arg vcenter_vms_path "pcf_vms" \
#   --arg vcenter_disks_path "pcf_disk" \
#   --argjson vsphere_allow_unverified_ssl false \
#   --argjson nsx_networking_enabled false \
#   --arg nsx_address "" \
#   --arg nsx_username "" \
#   --arg nsx_password "" \
#   --arg nsx_ca_certificate "" \
#   "$(cat iaas_configuration.jq)"
#
{
  "name": $deployment_prefix,
  "vcenter_host": $vsphere_server,
  "vcenter_username": $vsphere_user,
  "vcenter_password": $vsphere_password,
  "datacenter": $vcenter_datacenter,
  "disk_type": $disk_type,
  "ephemeral_datastores_string": $vcenter_ephemeral_datastores,
  "persistent_datastores_string": $vcenter_persistant_datastores,
  "bosh_template_folder": $vcenter_templates_path,
  "bosh_vm_folder": $vcenter_vms_path,
  "bosh_disk_path": $vcenter_disks_path,
  "ssl_verification_enabled": $vsphere_allow_unverified_ssl | not,
  "nsx_networking_enabled": $nsx_networking_enabled
}
+
# NSX networking. If not enabled, the following section is not required
if $nsx_networking_enabled then
  {
    "nsx_address": $nsx_address,
    "nsx_username": $nsx_username,
    "nsx_password": $nsx_password,
    "nsx_ca_certificate": $nsx_ca_certificate
  }
else
  .
end
