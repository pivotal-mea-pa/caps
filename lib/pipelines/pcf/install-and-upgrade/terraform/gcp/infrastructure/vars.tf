variable "prefix" {}
variable "environment" {}

variable "gcp_region" {}

variable "gcp_zone_1" {}

variable "gcp_zone_2" {}

variable "gcp_zone_3" {}

variable "gcp_storage_bucket_location" {}

variable "pcf_opsman_image_name" {}

# Network

variable "system_domain_prefix" {}
variable "apps_domain_prefix" {}

# Database

variable "pas_db_type" {}
variable "event_alerts_db_type" {}
variable "db_username" {}
variable "db_password" {}

# Certificates

variable "pcf_ert_ssl_cert" {
  default = ""
}

variable "pcf_ert_ssl_key" {
  default = ""
}

variable "pcf_saml_ssl_cert" {
  default = ""
}

variable "pcf_saml_ssl_key" {
  default = ""
}
