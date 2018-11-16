#
# Backend state for this config
#
terraform {
  backend "gcs" {}
}

#
# Retrieve the bootstrap state.
#

variable "bootstrap_state_bucket" {
  type = "string"
}

variable "bootstrap_state_prefix" {
  type = "string"
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config {
    bucket = "${var.bootstrap_state_bucket}"
    prefix = "${var.bootstrap_state_prefix}"
  }
}
