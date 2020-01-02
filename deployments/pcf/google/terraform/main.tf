#
# SSH Keys
#

locals {
  ssh_key_file_path = var.ssh_key_file_path == "" ? path.module : var.ssh_key_file_path
}

resource "local_file" "bastion-ssh-key" {
  content  = module.bootstrap.bastion_admin_sshkey
  filename = "${local.ssh_key_file_path}/bastion-admin-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${local.ssh_key_file_path}/bastion-admin-ssh-key.pem"
  }
}

resource "local_file" "default-ssh-key" {
  content  = module.bootstrap.default_openssh_private_key
  filename = "${local.ssh_key_file_path}/default-ssh-key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${local.ssh_key_file_path}/default-ssh-key.pem"
  }
}

#
# Backend state
#
terraform {
  backend "gcs" {}
}

#
# Read GCP access credentials from service account key file
#
data "external" "gcp_credentials" {
  program = ["cat", "${var.gcp_credentials}"]
}

#
# Availability zones within deployment region
#
data "google_compute_zones" "zones" {
  region = "${var.gcp_region}"
}

#
# Generate passwords that will be referenced
# by the PCF install automation pipelines.
#

resource "random_string" "concourse-admin-password" {
  length  = 10
  special = false
}

resource "random_string" "opsman-admin-password" {
  length  = 10
  special = false
}

resource "random_string" "common-admin-password" {
  length  = 10
  special = false
}

resource "random_string" "pas-system-dbpassword" {
  length  = 10
  special = false
}

resource "random_string" "credhub-encryption-key" {
  length  = 30
  special = false
}
