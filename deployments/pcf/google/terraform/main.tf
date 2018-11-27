#
# Backend state
#
terraform {
  backend "gcs" {}
}

#
# Read GCP access credentials from service account key file
#
data "external" "gcp_credentials" {
  program = ["cat", "${var.gcp_credentials}"]
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

resource "random_string" "common-admin-password" {
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
