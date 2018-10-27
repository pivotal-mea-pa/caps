#
# Cloud pre-configuration for Harbor
#

// Harbor external IP
resource "google_compute_address" "harbor" {
  name = "${var.prefix}-harbor"
}

// Harbor DNS
resource "google_dns_record_set" "harbor" {
  name         = "harbor.${local.env_domain}}."
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.harbor.address}"]
}

// Harbor target pool
resource "google_compute_target_pool" "harbor" {
  name = "${var.prefix}-harbor"
}

// Harbor tcp forwarding rule
resource "google_compute_forwarding_rule" "harbor" {
  name        = "${var.prefix}-harbor-lb"
  target      = "${google_compute_target_pool.harbor.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.harbor.address}"
}

// Allow access to Harbor resources
resource "google_compute_firewall" "harbor" {
  name    = "${var.prefix}-allow-harbor"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags = ["${google_compute_target_pool.harbor.name}"]
}
