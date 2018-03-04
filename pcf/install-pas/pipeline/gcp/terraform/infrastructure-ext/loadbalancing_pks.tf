// PKS public address
resource "google_compute_address" "pks-api" {
  name = "${var.prefix}-pks-api"
}

resource "google_dns_record_set" "wildcard-apps-dns" {
  name         = "*.pks.${var.pcf_ert_domain}."
  managed_zone = "${data.terraform_remote_state.bootstrap.vpc_dns_zone_name}"

  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_global_address.pks-api.address}"]
}

// PKS target pool
resource "google_compute_target_pool" "pks-api" {
  name = "${var.prefix}-pks-api"
}

// PKS API tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-api" {
  name        = "${var.prefix}-pks-api-lb"
  target      = "${google_compute_target_pool.pks-api.self_link}"
  port_range  = "9021"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.pks-api.address}"
}

// PKS UAA tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-uaa" {
  name        = "${var.prefix}-pks-uaa-lb"
  target      = "${google_compute_target_pool.pks-api.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.pks-api.address}"
}
