// PKS API Health check
resource "google_compute_health_check" "pks-tcp" {
  name = "${var.prefix}-pks-tcp"

  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2

  tcp_health_check {
    port = "9021"
  }
}

// PKS target pool
resource "google_compute_target_pool" "pks-api" {
  name = "${var.prefix}-pks-api"

  health_checks = [
    "${google_compute_health_check.pks-tcp.name}",
  ]
}

// PKS API tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-api" {
  name        = "${var.prefix}-pks-api-lb"
  target      = "${google_compute_target_pool.pks-api.self_link}"
  port_range  = "9021"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-tcp.address}"
}

// PKS UAA tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-uaa" {
  name        = "${var.prefix}-pks-uaa-lb"
  target      = "${google_compute_target_pool.pks-api.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-tcp.address}"
}
