// Allow ssh from public networks
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.prefix}-allow-ssh"
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
  name    = "${var.prefix}-allow-http"
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
  name    = "${var.prefix}-allow-https"
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
  name    = "${var.prefix}-allow-http-8080"
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
  name    = "${var.prefix}-allow-ert-all"
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

  target_tags = ["${var.prefix}", "${var.prefix}-opsman", "nat-traverse"]
  source_tags = ["${var.prefix}", "${var.prefix}-opsman", "nat-traverse"]
}

//// Allow access to Optional CF TCP router
resource "google_compute_firewall" "cf-tcp" {
  name    = "${var.prefix}-allow-cf-tcp"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  target_tags = ["${google_compute_target_pool.cf-tcp.name}"]
}

//// Allow access to ssh-proxy [Optional]
resource "google_compute_firewall" "cf-ssh-proxy" {
  name    = "${var.prefix}-allow-ssh-proxy"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  target_tags = ["${google_compute_target_pool.cf-ssh.name}", "diego-brain"]
}
