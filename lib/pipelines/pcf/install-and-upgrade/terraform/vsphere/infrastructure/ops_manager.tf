#
# Deploy Pivotal Operations Manager appliance
#

local {
  opsman_ip             = "${local.opsman_vcenter_ip}"
  opsman_netmask        = "${cidrnetmask(local.opsman_vcenter_network_cidr)}"
  opsman_gateway        = "${local.opsman_vcenter_network_gateway}"
  opsman_dns_servers    = "${data.terraform_remote_state.bootstrap.pcf_network_dns}"
  opsman_ntp_servers    = "${data.terraform_remote_state.bootstrap.pcf_network_ntp}"
  opsman_ssh_password   = "${data.terraform_remote_state.bootstrap.opsman_admin_password}"
  opsman_ssh_public_key = "${trimspace(data.terraform_remote_state.bootstrap.default_openssh_public_key)}"
  opsman_hostname       = "opsman.${local.environment}.${data.terraform_remote_state.bootstrap.vpc_dns_zone}"
}

#
# Ops Manager Instance
#

#data "external" "opsman-instance" {
#  program = ["${path.module}/upload_opsman_image.sh",
#    "${local.vcenter_datacenter}",
#    "${vsphere_folder.vms.path}",
	"${local.opsman_vcenter_cluster}",
    "${local.opsman_vcenter_network}",
	"${local.opsman_vcenter_datastore}",
    "${local.opsman_ip}",
    "${local.opsman_netmask}",
    "${local.opsman_gateway}",
    "${local.opsman_dns_servers}",
    "${local.opsman_ntp_servers}",
	"${local.opsman_ssh_password}",
    "${local.opsman_ssh_public_key}",
    "${local.opsman_hostname}",
	"${vsphere_virtual_disk.opsman-data-disk.vmdk_path}",
  ]
}

#
# Ops Manager data volume
#

resource "vsphere_virtual_disk" "opsman-data-disk" {
  size               = "100"
  vmdk_path          = "/${local.disks_path}/opsman-data.vmdk"
  datacenter         = "${data.vsphere_datacenter.dc.name}"
  datastore          = "${data.vsphere_datastore.ds.name}"
  type               = "thin"
  create_directories = "true"
}

#
# Ops Manager housekeeping automation script templates
#

data "template_file" "export-installation" {
  template = "${file("${path.module}/../../../../../../scripts/opsman/export-installation.sh")}"

  vars {
    opsman_dns_name       = "${local.opsman_dns_name}"
    opsman_admin_password = "${data.terraform_remote_state.bootstrap.opsman_admin_password}"
  }
}

data "template_file" "import-installation" {
  template = "${file("${path.module}/../../../../../../scripts/opsman/import-installation.sh")}"

  vars {
    opsman_dns_name       = "${local.opsman_dns_name}"
    opsman_admin_password = "${data.terraform_remote_state.bootstrap.opsman_admin_password}"
  }
}

data "template_file" "mount-opsman-data-volume" {
  template = "${file("${path.module}/../../../../../../scripts/utility/mount-volume.sh")}"

  vars {
    attached_device_name = "/dev/sdb"
    mount_directory      = "/data"
    world_readable       = "true"
  }
}
