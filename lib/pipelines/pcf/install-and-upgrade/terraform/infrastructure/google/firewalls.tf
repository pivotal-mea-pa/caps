// Allow ssh from public networks
resource "google_compute_firewall" "allow-ssh" {
  name    = "${local.prefix}-allow-ssh"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

// Allow http from public
resource "google_compute_firewall" "pcf-allow-http" {
  name    = "${local.prefix}-allow-http"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http", "router"]
}

// Allow https from public
resource "google_compute_firewall" "pcf-allow-https" {
  name    = "${local.prefix}-allow-https"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-https", "router"]
}

//// GO Router Health Checks
resource "google_compute_firewall" "pcf-allow-http-8080" {
  name    = "${local.prefix}-allow-http-8080"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["router"]
}

//// Create Firewall Rule for allow-ert-all com between bosh deployed ert jobs
//// This will match the default OpsMan tag configured for the deployment
resource "google_compute_firewall" "allow-ert-all" {
  name    = "${local.prefix}-allow-ert-all"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  target_tags = ["${local.prefix}", "${local.prefix}-opsman", "nat-traverse"]
  source_tags = ["${local.prefix}", "${local.prefix}-opsman", "nat-traverse"]
}

//// Allow access to Optional CF TCP router
resource "google_compute_firewall" "cf-tcp" {
  name    = "${local.prefix}-allow-cf-tcp"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  target_tags = ["${google_compute_target_pool.cf-tcp.name}"]
}

//// Allow access to ssh-proxy [Optional]
resource "google_compute_firewall" "cf-ssh-proxy" {
  name    = "${local.prefix}-allow-ssh-proxy"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  target_tags = ["${google_compute_target_pool.cf-ssh.name}", "diego-brain"]
}
