#
# Backend state for this config
#
terraform {
  backend "gcs" {}
}

#
# Retrieve the bootstrap state.
#

variable "terraform_state_bucket" {
  type = "string"
}

variable "pcf_state_prefix" {
  type = "string"
}

data "terraform_remote_state" "pcf" {
  backend = "gcs"

  config {
    bucket = "${var.terraform_state_bucket}"
    prefix = "${var.pcf_state_prefix}"
  }
}
