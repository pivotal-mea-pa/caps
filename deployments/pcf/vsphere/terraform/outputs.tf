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
# vCenter IaaS Environment
#

output "vsphere_server" {
  value = "${var.vsphere_server}"
}

output "vsphere_user" {
  value = "${var.vsphere_user}"
}

output "vsphere_password" {
  value = "${var.vsphere_password}"
}

output "vsphere_allow_unverified_ssl" {
  value = "${var.vsphere_allow_unverified_ssl}"
}

output "vcenter_datacenter" {
  value = "${var.vcenter_datacenter}"
}

output "vcenter_templates_path" {
  value = "${var.vcenter_templates_path}"
}

output "vcenter_vms_path" {
  value = "${var.vcenter_vms_path}"
}

output "vcenter_disks_path" {
  value = "${var.vcenter_disks_path}"
}

# Comma separated list of availability zone clusters
output "vcenter_clusters" {
  value = "${var.vcenter_clusters}"
}

# Comma separated list of ephemeral data stores
output "vcenter_ephemeral_datastores" {
  value = "${var.vcenter_ephemeral_datastores}"
}

# Comma separated list of persistent data stores
output "vcenter_persistant_datastores" {
  value = "${var.vcenter_persistant_datastores}"
}

#
# Terraform state attributes
#

output "terraform_state_bucket" {
  value = "${var.terraform_state_bucket}"
}

output "bootstrap_state_prefix" {
  value = "${local.bootstrap_state_prefix}"
}

#
# Certificate Subject data for certificate creation
#
output "company_name" {
  value = "${var.company_name}"
}

output "organization_name" {
  value = "${var.organization_name}"
}

output "locality" {
  value = "${var.locality}"
}

output "province" {
  value = "${var.province}"
}

output "country" {
  value = "${var.country}"
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

#
# Concourse Automation common attributes
#

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

output "pcf_terraform_templates_path" {
  value = "${var.pcf_terraform_templates_path}"
}

output "pcf_tile_templates_path" {
  value = "${var.pcf_terraform_templates_path}"
}

#
# PCF Environments
#

output "pcf_sandbox_environment" {
  value = "${var.pcf_environments[0]}"
}

#
# PCF Deployment Networks CIDRs
#

output "pcf_opsman_vcenter_config" {
  value = "${var.pcf_opsman_vcenter_config}"
}

output "pcf_networks" {
  value = "${var.pcf_networks}"
}

output "pcf_network_subnets" {
  value = "${var.pcf_network_subnets}"
}

output "pcf_network_dns" {
  value = "${local.bastion_admin_ip}"
}

#
# PCF Install params
#

output "pivnet_token" {
  value     = "${var.pivnet_token}"
  sensitive = true
}

output "opsman_admin_password" {
  value = "${random_string.opsman-admin-password.result}"
}

output "common_admin_password" {
  value = "${random_string.common-admin-password.result}"
}

output "pas_system_dbpassword" {
  value     = "${random_string.pas-system-dbpassword.result}"
  sensitive = true
}

output "credhub_encryption_key" {
  value     = "${random_string.credhub-encryption-key.result}"
  sensitive = true
}

output "notification_email" {
  value = "${var.notification_email}"
}

#
# Network resource attributes
#
output "dmz_network" {
  value = "${var.dmz_network}"
}

output "admin_network" {
  value = "${var.admin_network}"
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

output "bastion_admin_password" {
  value = "${module.bootstrap.bastion_admin_password}"
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
