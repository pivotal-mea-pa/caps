#
# Deploy Pivotal Operations Manager appliance
#

locals {
  opsman_vcenter_config = "${data.terraform_remote_state.bootstrap.pcf_opsman_vcenter_config[var.environment]}"

  vcenter_datacenter     = "${data.terraform_remote_state.bootstrap.vcenter_datacenter}"
  vcenter_templates_path = "${var.environment}_${data.terraform_remote_state.bootstrap.vcenter_templates_path}"
  vcenter_vms_path       = "${var.environment}_${data.terraform_remote_state.bootstrap.vcenter_vms_path}"
  vcenter_disks_path     = "${var.environment}_${data.terraform_remote_state.bootstrap.vcenter_disks_path}"

  opsman_vcenter_cluster   = "${lookup(local.opsman_vcenter_config, "cluster")}"
  opsman_vcenter_datastore = "${lookup(local.opsman_vcenter_config, "datastore")}"
  opsman_vcenter_network   = "${lookup(local.opsman_vcenter_config, "network")}"
}

#
# Lookup VCenter resources for Ops Manager deployment
#

data "vsphere_datacenter" "dc" {
  name = "${local.vcenter_datacenter}"
}

data "vsphere_compute_cluster" "cl" {
  name          = "${local.opsman_vcenter_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "ds" {
  name          = "${local.opsman_vcenter_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "nw" {
  name          = "${local.opsman_vcenter_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "opsman-template" {
  name          = "${local.vcenter_templates_path}/${var.pcf_opsman_image_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#
# VCenter folder for VPC
#

resource "vsphere_folder" "vms" {
  path          = "${local.vcenter_vms_path}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#
# Ops Manager Instance
#

resource "vsphere_virtual_machine" "opsman" {
  name   = "${var.pcf_opsman_image_name}}"
  folder = "${vsphere_folder.vms.path}"

  resource_pool_id = "${data.vsphere_compute_cluster.cl.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.ds.id}"

  guest_id  = "${data.vsphere_virtual_machine.opsman-template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.opsman-template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.nw.id}"
    adapter_type = "${data.vsphere_virtual_machine.opsman-template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.opsman-template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.opsman-template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.opsman-template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.opsman-template.id}"
  }
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
