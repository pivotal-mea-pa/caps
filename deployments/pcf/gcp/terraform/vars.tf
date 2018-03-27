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

variable "automation_pipelines_url" {
  default = "https://github.com/mevansam/caps.git"
}

variable "automation_pipelines_branch" {
  default = "master"
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
# 'product_name:product_slug/product_version_regex' as required by the pipeline at
# https://github.com/pivotal-cf/pcf-pipelines/tree/master/upgrade-tile.
variable "products" {
  type = "string"
}

# Email to send mysql service health alerts
variable "mysql_monitor_recipient_email" {
  type = "string"
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

#
# Bootstrap state attributes
#

variable "bootstrap_state_bucket" {
  type = "string"
}

variable "bootstrap_state_prefix" {
  type = "string"
}
