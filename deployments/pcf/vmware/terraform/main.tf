#
# Backend state
#
terraform {
  backend "s3" {}
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
