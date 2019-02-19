#
# Deploy Pivotal Operations Manager appliance
#

data "external" "get-opsman-image-archive" {
  program = ["${path.module}/scripts/get_opsman_image_archive.sh"]
}

data "template_file" "upload-opsman-image" {
  template = "${file("${path.module}/scripts/upload_opsman_image.sh")}"

  vars {
    opsman_image_name  = "${data.external.get-opsman-image-archive.result.image_name}"
    opsman_bucket_path = "${data.external.get-opsman-image-archive.result.bucket_path}"
  }
}

resource "null_resource" "upload-opsman-image" {
  provisioner "local-exec" {
    command = <<UPLOAD
/bin/bash <<'ESH'
${data.template_file.upload-opsman-image.rendered}
ESH
UPLOAD
  }

  triggers {
    opsman-image-name = "${data.external.get-opsman-image-archive.result.image_name}"
  }
}

resource "google_compute_instance" "ops-manager" {
  name = "${local.prefix}-ops-manager"

  tags = ["${local.prefix}", "${local.prefix}-opsman"]

  zone         = "${data.google_compute_zones.available.names[0]}"
  machine_type = "n1-standard-2"

  boot_disk {
    initialize_params {
      image = "${data.external.get-opsman-image-archive.result.image_name}"
      size  = 160
    }
  }

  attached_disk {
    source = "${google_compute_disk.opsman-data-disk.self_link}"
  }

  network_interface {
    subnetwork = "${local.infrastructure_subnetwork}"
  }

  metadata {
    ssh-keys = "ubuntu:${data.terraform_remote_state.bootstrap.default_openssh_public_key}"
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
      "/home/ubuntu/mount-opsman-data-volume.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "/home/ubuntu/export-installation.sh",
    ]

    when = "destroy"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${data.terraform_remote_state.bootstrap.default_openssh_private_key}"
    host        = "${self.network_interface.0.network_ip}"
  }

  depends_on = [
    "google_compute_network_peering.pcf-admin",
    "google_compute_network_peering.admin-pcf",
    "google_compute_firewall.admin-to-pcf-allow-all",
    "google_compute_subnetwork.pcf",
    "null_resource.upload-opsman-image",
  ]
}

resource "null_resource" "ops-manager" {
  provisioner "remote-exec" {
    inline = [
      "/home/ubuntu/import-installation.sh",
    ]
  }

  triggers {
    ops_manager_id = "${google_compute_instance.ops-manager.id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${data.terraform_remote_state.bootstrap.default_openssh_private_key}"
    host        = "${google_compute_instance.ops-manager.network_interface.0.address}"
  }

  depends_on = ["google_dns_record_set.ops-manager-dns"]
}

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

resource "google_compute_disk" "opsman-data-disk" {
  name = "${local.prefix}-opsman-data-disk"
  type = "pd-standard"
  zone = "${data.google_compute_zones.available.names[count.index]}"
  size = "100"
}

resource "google_storage_bucket" "director" {
  name          = "${local.prefix}-director"
  location      = "${data.terraform_remote_state.bootstrap.gcp_region}"
  force_destroy = true
}
