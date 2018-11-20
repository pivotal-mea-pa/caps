#
# Create storage bucket for backups
#
resource "google_storage_bucket" "backups" {
  name          = "${var.vpc_name}-backups"
  location      = "${var.gcp_region}"
  storage_class = "REGIONAL"

  force_destroy = true
}
