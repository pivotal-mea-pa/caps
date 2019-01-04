#
# Retrieves the bootstrap state and reference additiona 
# resources required to generate the pipeline params file.
#

data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config {
    endpoint = "${var.bootstrap_state_endpoint}"
    bucket   = "${var.bootstrap_state_bucket}"
    key      = "${var.bootstrap_state_prefix}"
  }
}
