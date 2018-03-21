#
# Backend state
#
terraform {
  backend "gcs" {}
}

#
# Availability zones within deployment region
#

data "google_compute_zones" "zones" {
  region = "${var.gcp_region}"
}

#
# Generate passwords that will be referenced
# by the PCF install automation pipelines.
#

resource "random_string" "concourse-admin-password" {
  length  = 10
  special = false
}

resource "random_string" "opsman-admin-password" {
  length  = 10
  special = false
}

resource "random_string" "pas-system-dbpassword" {
  length  = 10
  special = false
}

resource "random_string" "credhub-encryption-key" {
  length  = 30
  special = false
}
