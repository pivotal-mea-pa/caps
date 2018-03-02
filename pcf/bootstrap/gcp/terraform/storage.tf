#
# Create storage bucket for pcf-pipelines terraform state
#
resource "google_storage_bucket" "pas-terraform-state" {
  name          = "${var.vpc_name}-pas-state"
  location      = "${var.gcp_region}"
  storage_class = "REGIONAL"

  force_destroy = true

  versioning {
    enabled = true
  }
}
