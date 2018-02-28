#
# Outputs that will be saved to the Terraform state 
# and can be referenced for future configurations.
#

#
# GCP credentials
#

output "gcp_project" {
  value = "${var.gcp_project}"
}

output "gcp_credentials" {
  value     = "${file(var.gcp_credentials)}"
  sensitive = true
}

output "gcp_region" {
  value = "${var.gcp_region}"
}

output "gcp_storage_access_key" {
  value     = "${var.gcp_storage_access_key}"
  sensitive = true
}

output "gcp_storage_secret_key" {
  value     = "${var.gcp_storage_secret_key}"
  sensitive = true
}

#
# VPC configuration
#

output "vpc_name" {
  value = "${var.vpc_name}"
}

output "vpc_dns_zone" {
  value = "${var.vpc_dns_zone}"
}

output "vpc_parent_dns_zone_name" {
  value = "${var.vpc_parent_dns_zone_name}"
}

#
# PCF Install params
#

output "pas_terraform_state_bucket" {
  value = "${google_storage_bucket.pas-terraform-state.name}"
}

output "pivnet_token" {
  value     = "${var.pivnet_token}"
  sensitive = true
}

output "opsman_admin_password" {
  value = "${random_string.opsman-admin-password.result}"
}

output "pas_system_dbpassword" {
  value     = "${random_string.opsman-admin-password.result}"
  sensitive = true
}

output "credhub_encryption_key" {
  value     = "${random_string.credhub-encryption-key.result}"
  sensitive = true
}

output "mysql_monitor_recipient_email" {
  value = "${var.mysql_monitor_recipient_email}"
}

#
# Network resource attributes
#
output "dmz_network" {
  value = "${module.bootstrap.dmz_network}"
}

output "dmz_subnetwork" {
  value = "${module.bootstrap.dmz_subnetwork}"
}

output "engineering_network" {
  value = "${module.bootstrap.engineering_network}"
}

output "engineering_subnetwork" {
  value = "${module.bootstrap.engineering_subnetwork}"
}

#
# Bastion resource attributes
#
output "bastion_fqdn" {
  value = "${module.bootstrap.bastion_fqdn}"
}

output "bastion_admin_fqdn" {
  value = "${module.bootstrap.bastion_admin_fqdn}"
}

output "vpn_admin_password" {
  value = "${module.bootstrap.vpn_admin_password}"
}

output "default_openssh_public_key" {
  value = "${module.bootstrap.default_openssh_public_key}"
}

output "concourse_admin_password" {
  value = "${module.bootstrap.concourse_admin_password}"
}
