#
# Local Variables
#
locals {
  prefix = "${data.terraform_remote_state.bootstrap.vpc_name}-${var.environment}"

  # num_azs = "${min(data.terraform_remote_state.bootstrap.max_azs, length(data.google_compute_zones.available.names))}"
}

#
# External Variables
#

variable "environment" {}

variable "pcf_opsman_image_name" {}

# Network

variable "system_domain_prefix" {}
variable "apps_domain_prefix" {}

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
