#
# Virtual Network for PCF environment
#

resource "google_compute_network" "pcf-virt-net" {
  name = "${var.prefix}-virt-net"
}

// Ops Manager and Bosh Directory
resource "google_compute_subnetwork" "subnet-ops-manager" {
  name          = "${var.prefix}-subnet-infrastructure-${var.gcp_region}"
  ip_cidr_range = "192.168.101.0/26"
  network       = "${google_compute_network.pcf-virt-net.self_link}"
}

// ERT
resource "google_compute_subnetwork" "subnet-ert" {
  name          = "${var.prefix}-subnet-ert-${var.gcp_region}"
  ip_cidr_range = "192.168.16.0/22"
  network       = "${google_compute_network.pcf-virt-net.self_link}"
}

// Services Tile
resource "google_compute_subnetwork" "subnet-services-1" {
  name          = "${var.prefix}-subnet-services-1-${var.gcp_region}"
  ip_cidr_range = "192.168.20.0/22"
  network       = "${google_compute_network.pcf-virt-net.self_link}"
}

// Dynamic Services Tile
resource "google_compute_subnetwork" "subnet-dynamic-services-1" {
  name          = "${var.prefix}-subnet-dynamic-services-1-${var.gcp_region}"
  ip_cidr_range = "192.168.24.0/22"
  network       = "${google_compute_network.pcf-virt-net.self_link}"
}

#
# Peer perimeter admin network to PCF virtual network
#

resource "google_compute_network_peering" "pcf-admin" {
  name         = "${var.prefix}-pcf-admin"
  network      = "${google_compute_network.pcf-virt-net.self_link}"
  peer_network = "${data.terraform_remote_state.bootstrap.admin_network}"
}

resource "google_compute_network_peering" "admin-pcf" {
  name         = "${var.prefix}-admin-pcf"
  network      = "${data.terraform_remote_state.bootstrap.admin_network}"
  peer_network = "${google_compute_network.pcf-virt-net.self_link}"
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

  network = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "all"
  }

  direction = "INGRESS"

  source_ranges = ["${data.google_compute_subnetwork.admin.ip_cidr_range}"]
  target_tags   = ["${var.prefix}", "${var.prefix}-opsman"]
}
