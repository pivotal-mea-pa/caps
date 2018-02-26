#
# Create storage bucket for pcf-pipelines terraform state
#
resource "google_storage_bucket" "image-store" {
  name          = "pcf-tfacc-state-euw3"
  location      = "europe-west3"
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }
}
