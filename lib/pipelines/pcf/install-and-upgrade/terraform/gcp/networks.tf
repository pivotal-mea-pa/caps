#
# Virtual Network for PCF environment
#

locals {
  networks     = "${data.terraform_remote_state.bootstrap.pcf_networks[var.environment]}"
  subnet_names = "${keys(local.networks)}"

  subnet_links = "${zipmap(local.subnet_names, google_compute_subnetwork.pcf.*.self_link)}"
}

resource "google_compute_network" "pcf" {
  name                    = "${var.prefix}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "pcf" {
  count = "${length(local.subnet_names)}"

  name          = "${var.prefix}-subnet-${local.subnet_names[count.index]}"
  ip_cidr_range = "${local.networks[local.subnet_names[count.index]]}"
  network       = "${google_compute_network.pcf.self_link}"
}

data "external" "pcf-network-info" {
  count = "${length(local.subnet_names)}"

  program = [
    "echo",
    <<RESULT
{
  "network_name": "${replace(local.subnet_names[count.index], "/-[0-9]+$/", "")}",
  "subnet_name": "${local.subnet_names[count.index]}",
  "subnet_link": "${google_compute_subnetwork.pcf.*.self_link[count.index]}",
  "cidr": "${local.networks[local.subnet_names[count.index]]}",
  "gateway": "${cidrhost(local.networks[local.subnet_names[count.index]], 1)}",
  "reserved_range": "${
    cidrhost(local.networks[local.subnet_names[count.index]], 0)}-${
    cidrhost(local.networks[local.subnet_names[count.index]], 1)},${
    cidrhost(local.networks[local.subnet_names[count.index]], -2)}-${
    cidrhost(local.networks[local.subnet_names[count.index]], -1)}"
}
RESULT
    ,
  ]
}

#
# Peer perimeter admin network to PCF virtual network
#

resource "google_compute_network_peering" "pcf-admin" {
  name         = "${var.prefix}-pcf-admin"
  network      = "${google_compute_network.pcf.self_link}"
  peer_network = "${data.terraform_remote_state.bootstrap.admin_network}"
}

resource "google_compute_network_peering" "admin-pcf" {
  name         = "${var.prefix}-admin-pcf"
  network      = "${data.terraform_remote_state.bootstrap.admin_network}"
  peer_network = "${google_compute_network.pcf.self_link}"
}

#
# Allow access to internal resources in PCF virtual network from admin network
#

data "google_compute_subnetwork" "admin" {
  name   = "${basename(data.terraform_remote_state.bootstrap.admin_subnetwork)}"
  region = "${var.gcp_region}"
}

resource "google_compute_firewall" "admin-to-pcf-allow-all" {
  name = "${var.prefix}-admin-to-pcf-allow-all"

  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "all"
  }

  direction = "INGRESS"

  source_ranges = ["${data.google_compute_subnetwork.admin.ip_cidr_range}"]
  target_tags   = ["${var.prefix}", "${var.prefix}-opsman"]
}
