// Go Router Health check
resource "google_compute_http_health_check" "cf-gorouter" {
  name                = "${var.prefix}-gorouter"
  port                = 8080
  request_path        = "/health"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2
}

// TCP Router Health check
resource "google_compute_http_health_check" "cf-tcp" {
  name                = "${var.prefix}-tcp-lb"
  host                = "tcp.${local.system_domain}."
  port                = 80
  request_path        = "/health"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2
}

// GoRouter target pool
resource "google_compute_target_pool" "cf-gorouter" {
  name = "${var.prefix}-wss-logs"

  health_checks = [
    "${google_compute_http_health_check.cf-gorouter.name}",
  ]
}

// TCP Router target pool
resource "google_compute_target_pool" "cf-tcp" {
  name = "${var.prefix}-cf-tcp-lb"

  health_checks = [
    "${google_compute_http_health_check.cf-tcp.name}",
  ]
}

// SSH-Proxy target pool
resource "google_compute_target_pool" "cf-ssh" {
  name = "${var.prefix}-ssh-proxy"
}

// PKS target pool
resource "google_compute_target_pool" "pks" {
  name = "${var.prefix}-pks"
}

// Harbor target pool
resource "google_compute_target_pool" "harbor" {
  name = "${var.prefix}-harbor"
}

// Doppler forwarding rule
resource "google_compute_forwarding_rule" "cf-gorouter-wss" {
  name        = "${var.prefix}-gorouter-wss-lb"
  target      = "${google_compute_target_pool.cf-gorouter.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-gorouter-wss.address}"
}

// SSH Proxy forwarding rule
resource "google_compute_forwarding_rule" "cf-ssh" {
  name        = "${var.prefix}-ssh-proxy"
  target      = "${google_compute_target_pool.cf-ssh.self_link}"
  port_range  = "2222"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-ssh.address}"
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-tcp" {
  name        = "${var.prefix}-cf-tcp-lb"
  target      = "${google_compute_target_pool.cf-tcp.self_link}"
  port_range  = "1024-65535"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-tcp.address}"
}

// PKS API tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-api" {
  name        = "${var.prefix}-pks-api-lb"
  target      = "${google_compute_target_pool.pks.self_link}"
  port_range  = "9021"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.pks.address}"
}

// PKS UAA tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-uaa" {
  name        = "${var.prefix}-pks-uaa-lb"
  target      = "${google_compute_target_pool.pks.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.pks.address}"
}

// Harbor tcp forwarding rule
resource "google_compute_forwarding_rule" "harbor" {
  name        = "${var.prefix}-harbor-lb"
  target      = "${google_compute_target_pool.harbor.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.harbor.address}"
}
