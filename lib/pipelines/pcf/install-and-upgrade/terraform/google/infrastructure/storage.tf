resource "google_storage_bucket" "buildpacks" {
  name          = "${local.prefix}-buildpacks"
  location      = "${data.terraform_remote_state.bootstrap.gcp_region}"
  force_destroy = true
}

resource "google_storage_bucket" "droplets" {
  name          = "${local.prefix}-droplets"
  location      = "${data.terraform_remote_state.bootstrap.gcp_region}"
  force_destroy = true
}

resource "google_storage_bucket" "packages" {
  name          = "${local.prefix}-packages"
  location      = "${data.terraform_remote_state.bootstrap.gcp_region}"
  force_destroy = true
}

resource "google_storage_bucket" "resources" {
  name          = "${local.prefix}-resources"
  location      = "${data.terraform_remote_state.bootstrap.gcp_region}"
  force_destroy = true
}
