#
# Deploy Pivotal Operations Manager appliance
#

locals {
  opsman_ip             = "${local.opsman_vcenter_ip}"
  opsman_netmask        = "${cidrnetmask(local.opsman_vcenter_network_cidr)}"
  opsman_gateway        = "${local.opsman_vcenter_network_gateway}"
  opsman_dns_servers    = "${data.terraform_remote_state.bootstrap.outputs.pcf_network_dns}"
  opsman_ntp_servers    = "${data.terraform_remote_state.bootstrap.outputs.pcf_network_ntp}"
  opsman_ssh_password   = "${data.terraform_remote_state.bootstrap.outputs.opsman_admin_password}"
  opsman_ssh_public_key = "${trimspace(data.terraform_remote_state.bootstrap.outputs.default_openssh_public_key)}"
}

#
# Ops Manager Instance
#

data "external" "get-opsman-image-path" {
  program = ["${path.module}/scripts/get_opsman_image_path.sh"]
}

data "template_file" "create-opsman-instance" {
  template = "${file("${path.module}/scripts/create_opsman_instance.sh")}"

  vars = {
    opsman-image-path     = "${data.external.get-opsman-image-path.result.path}"
    vcenter_datacenter    = "${local.vcenter_datacenter}"
    vcenter_vms_path      = "${vsphere_folder.vms.path}"
    vcenter_resource_pool = "${data.vsphere_resource_pool.rp.name}"
    vcenter_network       = "${local.opsman_vcenter_network}"
    vcenter_datastore     = "${local.opsman_vcenter_datastore}"
    opsman_ip             = "${local.opsman_ip}"
    opsman_netmask        = "${local.opsman_netmask}"
    opsman_gateway        = "${local.opsman_gateway}"
    opsman_dns_servers    = "${local.opsman_dns_servers}"
    opsman_ntp_servers    = "${local.opsman_ntp_servers}"
    opsman_ssh_password   = "${local.opsman_ssh_password}"
    opsman_ssh_public_key = "${local.opsman_ssh_public_key}"
    opsman_hostname       = "${local.opsman_dns_name}"
    opsman_data_disk_path = "${vsphere_virtual_disk.opsman-data-disk.vmdk_path}"
  }
}

data "template_file" "delete-opsman-instance" {
  template = "${file("${path.module}/scripts/delete_opsman_instance.sh")}"

  vars = {
    vcenter_datacenter = "${local.vcenter_datacenter}"
    vcenter_vms_path   = "${vsphere_folder.vms.path}"
  }
}

resource "null_resource" "opsman-instance" {
  provisioner "local-exec" {
    command = <<CREATE
/bin/bash <<'ESH'
${data.template_file.create-opsman-instance.rendered}
ESH
CREATE
  }

  provisioner "file" {
    content     = "${data.template_file.mount-opsman-data-volume.rendered}"
    destination = "/home/ubuntu/mount-opsman-data-volume.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.import-installation.rendered}"
    destination = "/home/ubuntu/import-installation.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.export-installation.rendered}"
    destination = "/home/ubuntu/export-installation.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0744 /home/ubuntu/mount-opsman-data-volume.sh",
      "chmod 0744 /home/ubuntu/import-installation.sh",
      "chmod 0744 /home/ubuntu/export-installation.sh",
      "echo '${local.opsman_ssh_password}' | sudo -S sh -c /home/ubuntu/mount-opsman-data-volume.sh",
    ]
  }

  # On Destroy
  provisioner "remote-exec" {
    inline = [
      "/home/ubuntu/export-installation.sh",
    ]

    when = "destroy"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = <<DESTROY
/bin/bash <<'ESH'
${data.template_file.delete-opsman-instance.rendered}
ESH
DESTROY
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${data.terraform_remote_state.bootstrap.outputs.default_openssh_private_key}"
    host        = "${local.opsman_ip}"
  }

  triggers = {
    opsman-image-archive = "${data.external.get-opsman-image-path.result.path}"
  }

  depends_on = [
    "vsphere_folder.vms",
    "vsphere_virtual_disk.opsman-data-disk",
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

  vars = {
    opsman_dns_name       = "${local.opsman_dns_name}"
    opsman_admin_password = "${data.terraform_remote_state.bootstrap.outputs.opsman_admin_password}"
  }
}

data "template_file" "import-installation" {
  template = "${file("${path.module}/../../../../../../scripts/opsman/import-installation.sh")}"

  vars = {
    opsman_dns_name       = "${local.opsman_dns_name}"
    opsman_admin_password = "${data.terraform_remote_state.bootstrap.outputs.opsman_admin_password}"
  }
}

data "template_file" "mount-opsman-data-volume" {
  template = "${file("${path.module}/../../../../../../scripts/utility/mount-volume.sh")}"

  vars = {
    attached_device_name = "/dev/sdb"
    mount_directory      = "/data"
    world_readable       = "true"
  }
}
