#
# This config file attaches the PCF reference 
# GCP configuration to the Bootstrap VCP.
#

variable "bootstrap_state_bucket" {
  type = "string"
}

variable "bootstrap_state_prefix" {
  type = "string"
}

# Import Bootstrap state
data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config {
    bucket = "${var.bootstrap_state_bucket}"
    prefix = "${var.bootstrap_state_prefix}"
  }
}

#
# Add Name Servers for ERT zone to bootstrap VPC zone.
#
data "google_dns_managed_zone" "vpc" {
  name = "${data.terraform_remote_state.bootstrap.vpc_dns_zone_name}"
}

resource "google_dns_record_set" "vpc" {
  name         = "${google_dns_managed_zone.env_dns_zone.dns_name}"
  managed_zone = "${data.google_dns_managed_zone.vpc.name}"

  type = "NS"
  ttl  = 300

  rrdatas = [
    "${google_dns_managed_zone.env_dns_zone.name_servers.0}",
    "${google_dns_managed_zone.env_dns_zone.name_servers.1}",
    "${google_dns_managed_zone.env_dns_zone.name_servers.2}",
    "${google_dns_managed_zone.env_dns_zone.name_servers.3}",
  ]
}

#
# Peer perimeter engineering network to PCF virtual network
#

resource "google_compute_network_peering" "pcf-engineering" {
  name         = "${var.prefix}-pcf-engineering"
  network      = "${google_compute_network.pcf-virt-net.self_link}"
  peer_network = "${data.terraform_remote_state.bootstrap.engineering_network}"
}

resource "google_compute_network_peering" "engineering-pcf" {
  name         = "${var.prefix}-engineering-pcf"
  network      = "${data.terraform_remote_state.bootstrap.engineering_network}"
  peer_network = "${google_compute_network.pcf-virt-net.self_link}"
}

#
# Allow access to internal resources in PCF virtual network from engineering network
#

data "google_compute_subnetwork" "engineering" {
  name   = "${basename(data.terraform_remote_state.bootstrap.engineering_subnetwork)}"
  region = "${var.gcp_region}"
}

resource "google_compute_firewall" "engineering-to-pcf-allow-all" {
  name = "${var.prefix}-engineering-to-pcf-allow-all"

  network = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "all"
  }

  direction = "INGRESS"

  source_ranges = ["${data.google_compute_subnetwork.engineering.ip_cidr_range}"]
  target_tags   = ["${var.prefix}", "${var.prefix}-opsman"]
}
