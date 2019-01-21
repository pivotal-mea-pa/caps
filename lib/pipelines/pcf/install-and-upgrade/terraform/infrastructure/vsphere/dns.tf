#
# PCF DNS Zone and Names 
#

locals {
  bootstrap_domain = "${data.terraform_remote_state.bootstrap.vpc_dns_zone}"
  env_domain       = "${var.environment}.${local.bootstrap_domain}"
  system_domain    = "${var.system_domain_prefix}.${local.env_domain}"
  apps_domain      = "${var.apps_domain_prefix}.${local.env_domain}"

  opsman_dns_name = "opsman.${local.env_domain}"

  ha_proxy_ip = "${lookup(local.pcf_static_ips, "pas_haproxy_ip", "")}"
}

#
# Add internal DNS records
#
# Since PowerDNS setup uses a SQLite backend
# the updates need to happen serially as 
# concurrent updates can fail as the database
# file is locked for each update.
#

resource "powerdns_record" "opsman" {
  zone    = "${local.env_domain}."
  name    = "${local.opsman_dns_name}."
  type    = "A"
  ttl     = 3600
  records = ["${local.opsman_vcenter_ip}"]
}

resource "powerdns_record" "wildcard-apps-dns" {
  count = "${length(local.ha_proxy_ip) > 0 ? 1 : 0}"

  zone    = "${local.env_domain}."
  name    = "*.${local.apps_domain}."
  type    = "A"
  ttl     = 3600
  records = ["${local.ha_proxy_ip}"]

  # depends_on = ["powerdns_record.opsman"]
}

resource "powerdns_record" "wildcard-sys-dns" {
  count = "${length(local.ha_proxy_ip) > 0 ? 1 : 0}"

  zone    = "${local.env_domain}."
  name    = "*.${local.system_domain}."
  type    = "A"
  ttl     = 3600
  records = ["${local.ha_proxy_ip}"]

  # depends_on = ["powerdns_record.wildcard-apps-dns"]
}

resource "powerdns_record" "app-ssh-dns" {
  count = "${length(local.ha_proxy_ip) > 0 ? 1 : 0}"

  zone    = "${local.env_domain}."
  name    = "ssh.${local.system_domain}."
  type    = "A"
  ttl     = 3600
  records = ["${local.ha_proxy_ip}"]

  # depends_on = ["powerdns_record.wildcard-sys-dns"]
}

resource "powerdns_record" "doppler-dns" {
  count = "${length(local.ha_proxy_ip) > 0 ? 1 : 0}"

  zone    = "${local.env_domain}."
  name    = "doppler.${local.system_domain}."
  type    = "A"
  ttl     = 3600
  records = ["${local.ha_proxy_ip}"]

  # depends_on = ["powerdns_record.app-ssh-dns"]
}

resource "powerdns_record" "loggregator-dns" {
  count = "${length(local.ha_proxy_ip) > 0 ? 1 : 0}"

  zone    = "${local.env_domain}."
  name    = "loggregator.${local.system_domain}."
  type    = "A"
  ttl     = 3600
  records = ["${local.ha_proxy_ip}"]

  # depends_on = ["powerdns_record.doppler-dns"]
}

resource "powerdns_record" "tcp-dns" {
  count = "${length(local.ha_proxy_ip) > 0 ? 1 : 0}"

  zone    = "${local.env_domain}."
  name    = "tcp.${local.env_domain}."
  type    = "A"
  ttl     = 3600
  records = ["${local.ha_proxy_ip}"]

  # depends_on = ["powerdns_record.loggregator-dns"]
}
