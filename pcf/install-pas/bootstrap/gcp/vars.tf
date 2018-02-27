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

variable "opsman_password" {
  type = "string"
}

variable "mysql_monitor_recipient_email" {
  type = "string"
}
