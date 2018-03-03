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

variable "vpc_dns_zone" {
  type = "string"
}

variable "vpc_parent_dns_zone_name" {
  type = "string"
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

variable "mysql_monitor_recipient_email" {
  type = "string"
}

# List of products to install. This should be a comma separated list of 
# 'product_name:product_slug/product_version_regex' as required by the pipeline at
# https://github.com/pivotal-cf/pcf-pipelines/tree/master/upgrade-tile.
variable "products" {
  type = "string"
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

variable "automation_pipeline_branch" {
  default = "master"
}
