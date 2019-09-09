#
# Backend state for this config
#
terraform {
  backend "s3" {}
}

#
# Retrieve the bootstrap state.
#

variable "bootstrap_state_endpoint" {
  default = ""
}

variable "bootstrap_state_bucket" {
  type = "string"
}

variable "bootstrap_state_prefix" {
  type = "string"
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    endpoint = "${var.bootstrap_state_endpoint}"
    bucket   = "${var.bootstrap_state_bucket}"
    key      = "${var.bootstrap_state_prefix}"
  }
}
