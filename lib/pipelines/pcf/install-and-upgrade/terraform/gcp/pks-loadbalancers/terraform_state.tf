#
# Backend state for this config
#
terraform {
  backend "gcs" {}
}

#
# Retrieve the bootstrap state.
#

variable "infrastructure_state_bucket" {
  type = "string"
}

variable "infrastructure_state_prefix" {
  type = "string"
}

data "terraform_remote_state" "pcf" {
  backend = "gcs"

  config {
    bucket = "${var.infrastructure_state_bucket}"
    prefix = "${var.infrastructure_state_prefix}"
  }
}
