// Global IP for PCF API & Apps
resource "google_compute_global_address" "pcf" {
  name = "${local.prefix}-global-pcf"
}

// Static IP address for forwarding rule for doppler
resource "google_compute_address" "cf-gorouter-wss" {
  name = "${local.prefix}-gorouter-wss"
}

// Static IP address for forwarding rule for sshproxy
resource "google_compute_address" "cf-ssh" {
  name = "${local.prefix}-ssh-proxy"
}

// Static IP address for forwarding rule for TCP LB
resource "google_compute_address" "cf-tcp" {
  name = "${local.prefix}-tcp-lb"
}

// Static IP address for OpsManager
resource "google_compute_address" "opsman" {
  name = "${local.prefix}-opsman"
}
