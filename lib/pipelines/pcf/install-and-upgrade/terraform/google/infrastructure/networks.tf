#
# Virtual Network for PCF environment
#

locals {
  networks = "${data.terraform_remote_state.bootstrap.pcf_networks[var.environment]}"

  service_networks = "${split(",", local.networks["service_networks"])}"
  subnet_names     = "${split(",", local.networks["subnet_config_order"])}"
  subnet_cidrs     = "${data.terraform_remote_state.bootstrap.pcf_network_subnets[var.environment]}"

  subnets = "${zipmap(local.subnet_names, google_compute_subnetwork.pcf.*.name)}"

  singleton_zone            = "${data.google_compute_zones.available.names[0]}"
  infrastructure_subnetwork = "${local.prefix}-subnet-infrastructure"
}

data "google_compute_zones" "available" {
  region = "${data.terraform_remote_state.bootstrap.gcp_region}"
}

resource "google_compute_network" "pcf" {
  name                    = "${local.prefix}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "pcf" {
  count = "${length(local.subnet_names)}"

  name          = "${local.prefix}-subnet-${local.subnet_names[count.index]}"
  ip_cidr_range = "${local.subnet_cidrs[local.subnet_names[count.index]]}"
  network       = "${google_compute_network.pcf.self_link}"
}

data "external" "pcf-network-info" {
  count = "${length(local.subnet_names)}"

  program = [
    "echo",
    <<RESULT
{
  "network_name": "${replace(local.subnet_names[count.index], "/-[0-9]+$/", "")}",
  "is_service_network": "${contains(local.service_networks, replace(local.subnet_names[count.index], "/-[0-9]+$/", ""))}",
  "iaas_identifier": "${google_compute_network.pcf.name}/${local.subnets[local.subnet_names[count.index]]}/${data.terraform_remote_state.bootstrap.gcp_region}",
  "cidr": "${local.subnet_cidrs[local.subnet_names[count.index]]}",
  "gateway": "${cidrhost(local.subnet_cidrs[local.subnet_names[count.index]], 1)}",
  "reserved_ip_ranges": "${
    cidrhost(local.subnet_cidrs[local.subnet_names[count.index]], 0)}-${
    cidrhost(local.subnet_cidrs[local.subnet_names[count.index]], 9)},${
    cidrhost(local.subnet_cidrs[local.subnet_names[count.index]], -2)}-${
    cidrhost(local.subnet_cidrs[local.subnet_names[count.index]], -1)}",
  "dns": "${data.terraform_remote_state.bootstrap.pcf_network_dns}",
  "availability_zone_names": "${join(",", data.google_compute_zones.available.names)}"
}
RESULT
    ,
  ]
}

#
# Peer perimeter admin network to PCF virtual network
#

resource "google_compute_network_peering" "pcf-admin" {
  name         = "${local.prefix}-pcf-admin"
  network      = "${google_compute_network.pcf.self_link}"
  peer_network = "${data.terraform_remote_state.bootstrap.admin_network}"
}

resource "google_compute_network_peering" "admin-pcf" {
  name         = "${local.prefix}-admin-pcf"
  network      = "${data.terraform_remote_state.bootstrap.admin_network}"
  peer_network = "${google_compute_network.pcf.self_link}"
}

#
# Allow access to internal resources in PCF virtual network from admin network
#

data "google_compute_subnetwork" "admin" {
  name   = "${basename(data.terraform_remote_state.bootstrap.admin_subnetwork)}"
  region = "${data.terraform_remote_state.bootstrap.gcp_region}"
}

resource "google_compute_firewall" "admin-to-pcf-allow-all" {
  name = "${local.prefix}-admin-to-pcf-allow-all"

  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "all"
  }

  direction = "INGRESS"

  source_ranges = ["${data.google_compute_subnetwork.admin.ip_cidr_range}"]
  target_tags   = ["${local.prefix}", "${local.prefix}-opsman"]
}
