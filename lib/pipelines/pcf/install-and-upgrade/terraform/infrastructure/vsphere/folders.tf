#
# VCenter resource folders
#

locals {
  templates_path = "${local.prefix}_${data.terraform_remote_state.bootstrap.vcenter_templates_path}"
  vms_path       = "${local.prefix}_${data.terraform_remote_state.bootstrap.vcenter_vms_path}"
  disks_path     = "${local.prefix}_${data.terraform_remote_state.bootstrap.vcenter_disks_path}"
}

resource "vsphere_folder" "templates" {
  path          = "${local.templates_path}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"

  provisioner "local-exec" {
    when = "destroy"

    command = <<CREATE
govc ls /${local.vcenter_datacenter}/vm/${local.templates_path} \
  | grep -e '/[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*' \
  | xargs govc object.destroy
CREATE
  }
}

resource "vsphere_folder" "vms" {
  path          = "${local.vms_path}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"

  provisioner "local-exec" {
    when = "destroy"

    command = <<CREATE
govc ls /${local.vcenter_datacenter}/vm/${local.vms_path} \
  | grep -e '/[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*' \
  | xargs govc object.destroy
CREATE
  }
}
