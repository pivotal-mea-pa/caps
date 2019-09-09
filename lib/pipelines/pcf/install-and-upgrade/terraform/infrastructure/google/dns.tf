#
# PCF DNS Zone and Names 
#

locals {
  bootstrap_domain = "${substr(data.google_dns_managed_zone.vpc.dns_name, 0, length(data.google_dns_managed_zone.vpc.dns_name)-1)}"
  env_domain       = "${var.environment}.${local.bootstrap_domain}"
  system_domain    = "${var.system_domain_prefix}.${local.env_domain}"
  apps_domain      = "${var.apps_domain_prefix}.${local.env_domain}"

  opsman_dns_name = "opsman.${local.env_domain}"
}

resource "google_dns_managed_zone" "env_dns_zone" {
  name     = "${replace("${local.env_domain}", ".", "-")}"
  dns_name = "${local.env_domain}."
}

resource "google_dns_record_set" "ops-manager-dns" {
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  name = "${local.opsman_dns_name}."
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_instance.ops-manager.network_interface.0.network_ip}"]
}

resource "google_dns_record_set" "wildcard-apps-dns" {
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  name = "*.${local.apps_domain}."
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_global_address.pcf.address}"]
}

resource "google_dns_record_set" "wildcard-sys-dns" {
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  name = "*.${local.system_domain}."
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_global_address.pcf.address}"]
}

resource "google_dns_record_set" "app-ssh-dns" {
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  name = "ssh.${local.system_domain}."
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.cf-ssh.address}"]
}

resource "google_dns_record_set" "doppler-dns" {
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  name = "doppler.${local.system_domain}."
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.cf-gorouter-wss.address}"]
}

resource "google_dns_record_set" "loggregator-dns" {
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  name = "loggregator.${local.system_domain}."
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.cf-gorouter-wss.address}"]
}

resource "google_dns_record_set" "tcp-dns" {
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  name = "tcp.${local.env_domain}."
  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.cf-tcp.address}"]
}

#
# Add Name Servers for ERT zone to bootstrap VPC zone.
#

data "google_dns_managed_zone" "vpc" {
  name = "${data.terraform_remote_state.bootstrap.outputs.vpc_dns_zone_name}"
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
