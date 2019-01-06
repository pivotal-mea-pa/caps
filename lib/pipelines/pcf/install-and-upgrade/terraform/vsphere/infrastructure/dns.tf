#
# PCF DNS Zone and Names 
#

locals {
  bootstrap_domain = "${data.terraform_remote_state.bootstrap.vpc_dns_zone}"

  env_domain    = "${var.environment}.${local.bootstrap_domain}"
  system_domain = "${var.system_domain_prefix}.${local.env_domain}"
  apps_domain   = "${var.apps_domain_prefix}.${local.env_domain}"

  opsman_dns_name = "opsman.${local.env_domain}"
}

output "env_domain" {
  value = "${local.env_domain}"
}

output "system_domain" {
  value = "${local.system_domain}"
}

output "apps_domain" {
  value = "${local.apps_domain}"
}

output "opsman_dns_name" {
  value = "${local.opsman_dns_name}"
}
