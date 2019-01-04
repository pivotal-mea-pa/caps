#
# Retrieves the bootstrap state and reference additiona 
# resources required to generate the pipeline params file.
#

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config {
    bucket = "${var.bootstrap_state_bucket}"
    prefix = "${var.bootstrap_state_prefix}"
  }
}
