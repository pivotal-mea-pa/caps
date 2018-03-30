#
# Outputs that will be saved to the Terraform state 
# and can be referenced for future configurations.
#

#
# Root CA for signing self-signed cert
#
output "root_ca_key" {
  value = "${module.bootstrap.root_ca_key}"
}

output "root_ca_cert" {
  value = "${module.bootstrap.root_ca_cert}"
}

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
# Terraform state attributes
#

variable "terraform_state_bucket" {
  value = "${var.terraform_state_bucket}"
}

variable "bootstrap_state_prefix" {
  value = "${var.bootstrap_state_prefix}"
}

#
# Certificate Subject data for certificate creation
#
output "company_name" {
  value = "string"
}

output "organization_name" {
  value = "string"
}

output "locality" {
  value = "string"
}

output "province" {
  value = "string"
}

output "country" {
  value = "string"
}

#
# VPC configuration
#

output "vpc_name" {
  value = "${var.vpc_name}"
}

output "max_azs" {
  value = "${var.max_azs}"
}

output "vpc_dns_zone" {
  value = "${var.vpc_dns_zone}"
}

output "vpc_dns_zone_name" {
  value = "${module.bootstrap.vpc_dns_zone_name}"
}

#
# Concourse Automation common attributes
#

output "locale" {
  value = "${var.locale}"
}

output "automation_pipelines_repo" {
  value = "${var.automation_pipelines_repo}"
}

output "automation_pipelines_branch" {
  value = "${var.automation_pipelines_branch}"
}

#
# Automation extensions git repository
#

output "automation_extensions_repo" {
  value = "${var.automation_extensions_repo}"
}

output "automation_extensions_branch" {
  value = "${var.automation_extensions_repo_branch}"
}

# Path to terraform templates for creating PCF PAS infrastructure
output "pcf_pas_terraform_templates_path" {
  value = "${var.pcf_pas_terraform_templates_path}"
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
  value     = "${random_string.pas-system-dbpassword.result}"
  sensitive = true
}

output "credhub_encryption_key" {
  value     = "${random_string.credhub-encryption-key.result}"
  sensitive = true
}

output "opsman_major_minor_version" {
  value = "${var.opsman_major_minor_version}"
}

output "ert_major_minor_version" {
  value = "${var.ert_major_minor_version}"
}

output "ert_errands_to_disable" {
  value = "${var.ert_errands_to_disable}"
}

output "mysql_monitor_recipient_email" {
  value = "${var.mysql_monitor_recipient_email}"
}

#
# Backup / Restore pipeline params
#

output "backups_bucket" {
  value = "${google_storage_bucket.backups.name}"
}

output "backup_interval" {
  value = "${var.backup_interval}"
}

output "backup_interval_start" {
  value = "${var.backup_interval_start}"
}

output "backup_interval_stop" {
  value = "${var.backup_interval_stop}"
}

output "backup_age" {
  value = "${var.backup_age}"
}

#
# Stop / Start pipeline event trigger time periods
#

output "pcf_stop_at" {
  value = "${var.pcf_stop_at}"
}

output "pcf_stop_trigger_days" {
  value = "${var.pcf_stop_trigger_days}"
}

output "pcf_start_at" {
  value = "${var.pcf_start_at}"
}

output "pcf_start_trigger_days" {
  value = "${var.pcf_start_trigger_days}"
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

output "mgmt_network" {
  value = "${module.bootstrap.mgmt_network}"
}

output "mgmt_subnetwork" {
  value = "${module.bootstrap.mgmt_subnetwork}"
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

output "concourse_admin_password" {
  value = "${random_string.concourse-admin-password.result}"
}

#
# Default SSH key to use within VPC
#
output "default_openssh_public_key" {
  value = "${module.bootstrap.default_openssh_public_key}"
}

output "default_openssh_private_key" {
  value = "${module.bootstrap.default_openssh_private_key}"
}
