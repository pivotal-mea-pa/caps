resource "google_compute_instance" "ops-manager" {
  name         = "${var.prefix}-ops-manager"
  depends_on   = ["google_compute_subnetwork.subnet-ops-manager"]
  machine_type = "n1-standard-2"
  zone         = "${var.gcp_zone_1}"

  tags = ["${var.prefix}", "${var.prefix}-opsman"]

  boot_disk {
    initialize_params {
      image = "${var.pcf_opsman_image_name}"
      size  = 160
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet-ops-manager.name}"
  }

  metadata {
    ssh-keys = "ubuntu:${data.terraform_remote_state.bootstrap.default_openssh_public_key}"
  }
}

resource "google_storage_bucket" "director" {
  name          = "${var.prefix}-director"
  location      = "${var.gcp_storage_bucket_location}"
  force_destroy = true
}
