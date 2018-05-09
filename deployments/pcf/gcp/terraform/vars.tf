#
# Externalized Variables
#

#
# GCP credentials
#

variable "gcp_project" {
  type = "string"
}

variable "gcp_credentials" {
  type = "string"
}

variable "gcp_region" {
  type = "string"
}

variable "gcp_storage_access_key" {
  type = "string"
}

variable "gcp_storage_secret_key" {
  type = "string"
}

#
# Terraform state attributes
#

variable "terraform_state_bucket" {
  type = "string"
}

variable "bootstrap_state_prefix" {
  type = "string"
}

#
# Certificate Subject data for certificate creation
#
variable "company_name" {
  default = "Pivotal Services"
}

variable "organization_name" {
  default = "PSO EMEA"
}

variable "locality" {
  default = "Dubai"
}

variable "province" {
  default = "Dubayy"
}

variable "country" {
  default = "AE"
}

#
# VPC configuration
#

variable "vpc_name" {
  type = "string"
}

variable "max_azs" {
  default = "1"
}

variable "vpc_dns_zone" {
  type = "string"
}

variable "vpc_parent_dns_zone_name" {
  type = "string"
}

#
# Bastion access configuration
#
variable "bastion_host_name" {
  default = "bastion"
}

variable "bastion_admin_ssh_port" {
  default = "22"
}

# This needs to be a name other than 'root' or 'admin' otherwise 
# the user setup on the bastion will fail and you will be unable 
# to login to the instance.
variable "bastion_admin_user" {
  type = "string"
}

variable "bastion_setup_vpn" {
  type = "string"
}

variable "bastion_vpn_port" {
  default = "2295"
}

variable "bastion_vpn_protocol" {
  default = "udp"
}

variable "bastion_vpn_network" {
  default = "192.168.111.0/24"
}

variable "bastion_allow_public_ssh" {
  default = ""
}

#
# Local file path to write SSH private key for bastion instance
#
variable "ssh_key_file_path" {
  default = ""
}

#
# Jumpbox
#

variable "deploy_jumpbox" {
  default = "false"
}

variable "jumpbox_data_disk_size" {
  default = "160"
}

#
# Concourse Automation common attributes
#

# Locale to use for time resources
variable "locale" {
  type = "string"
}

variable "automation_pipelines_repo" {
  default = "https://github.com/mevansam/caps.git"
}

variable "automation_pipelines_branch" {
  default = "master"
}

#
# Automation extensions git repository
#

variable "automation_extensions_repo" {
  default = "https://github.com/mevansam/caps.git"
}

variable "automation_extensions_repo_branch" {
  default = "master"
}

# Path to terraform templates for creating PCF PAS infrastructure
variable "pcf_pas_terraform_templates_path" {
  default = "lib/pipelines/pcf/install-and-upgrade/terraform/gcp"
}

#
# PCF Install params
#

variable "pivnet_token" {
  type = "string"
}

# PCF Ops Manager minor version to track
variable "opsman_major_minor_version" {
  type = "string"
}

# PCF Elastic Runtime minor version to track
variable "ert_major_minor_version" {
  type = "string"
}

# Errands to disable prior to deploying ERT
# Valid values:
#   all
#   none
#   "" (empty string)
#   Any combination of the following, separated by comma:
#     smoke-tests
#     push-apps-manager
#     notifications
#     notifications-ui
#     push-pivotal-account
#     autoscaling
#     autoscaling-register-broker
#     nfsbrokerpush
variable "ert_errands_to_disable" {
  default = "none"
}

# List of products to install. This should be a comma separated list of 
# 'product_name:product_slug/product_version_regex[:errands to disable]'.
# The 'errands to disable' field is optional and has the same format
# as the 'ert_errands_to_disable' variable.
variable "products" {
  type = "string"
}

# Email to send mysql service health alerts
variable "mysql_monitor_recipient_email" {
  type = "string"
}

# Number of Diego Cells to deploy
variable "num_diego_cells" {
  default = "1"
}

#
# Backup / Restore pipeline params
#

variable "backup_interval" {
  default = "1h"
}

variable "backup_interval_start" {
  default = "02:00 AM"
}

variable "backup_interval_stop" {
  default = "02:30 AM"
}

variable "backup_age" {
  default = "2"
}

#
# Stop / Start event pipeline trigger time periods
#

# Time in 24h format (HH:MM) when deployments in the
# PCF environment should be stopped and VMs shutdown
variable "pcf_stop_at" {
  default = "0"
}

variable "pcf_stop_trigger_days" {
  default = "[Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]"
}

# Time in 24h format (HH:MM) when deployments
# in the PCF environment should be started
variable "pcf_start_at" {
  default = "0"
}

variable "pcf_start_trigger_days" {
  default = "[Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]"
}
