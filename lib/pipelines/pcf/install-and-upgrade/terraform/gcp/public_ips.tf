// Global IP for PCF API & Apps
resource "google_compute_global_address" "pcf" {
  name = "${var.prefix}-global-pcf"
}

// Static IP address for forwarding rule for doppler
resource "google_compute_address" "cf-gorouter-wss" {
  name = "${var.prefix}-gorouter-wss"
}

// Static IP address for forwarding rule for sshproxy
resource "google_compute_address" "cf-ssh" {
  name = "${var.prefix}-ssh-proxy"
}

// Static IP address for forwarding rule for TCP LB
resource "google_compute_address" "cf-tcp" {
  name = "${var.prefix}-tcp-lb"
}

// Static IP address for OpsManager
resource "google_compute_address" "opsman" {
  name = "${var.prefix}-opsman"
}

// PKS static address
resource "google_compute_address" "pks-api" {
  name = "${var.prefix}-pks-api"
}
