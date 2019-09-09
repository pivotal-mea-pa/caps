#
# Local Variables
#
locals {
  prefix  = "${data.terraform_remote_state.bootstrap.outputs.vpc_name}-${var.environment}"
  num_azs = "${min(data.terraform_remote_state.bootstrap.outputs.max_azs, length(data.google_compute_zones.available.names))}"
}

#
# External Variables
#

variable "environment" {}

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
