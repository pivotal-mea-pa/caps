#
# Cloud pre-configuration for PKS
#

// PKS Kubernetes cluster external IPs
resource "google_compute_address" "k8s" {
  count = "${length(var.clusters)}"
  name  = "${data.terraform_remote_state.pcf.outputs.deployment_prefix}-${var.clusters[count.index]}"
}

// PKS Kubernetes cluster API DNS names
resource "google_dns_record_set" "k8s" {
  count = "${length(var.clusters)}"
  name  = "${var.clusters[count.index]}.${data.terraform_remote_state.pcf.outputs.env_domain}."

  managed_zone = "${data.terraform_remote_state.pcf.outputs.env_dns_zone_name}"

  type = "A"
  ttl  = 300

  rrdatas = ["${element(google_compute_address.k8s.*.address, count.index)}"]
}

// PKS Kubernetes cluster API backend health check
resource "google_compute_health_check" "k8s" {
  count = "${length(var.clusters)}"
  name  = "${data.terraform_remote_state.pcf.outputs.deployment_prefix}-${var.clusters[count.index]}"

  https_health_check {
    host         = "${var.clusters[count.index]}.${data.terraform_remote_state.pcf.outputs.env_domain}."
    port         = 8443
    request_path = "/healthz"
  }

  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2
}

// PKS Kubernetes cluster target pools
resource "google_compute_target_pool" "k8s" {
  count = "${length(var.clusters)}"
  name  = "${data.terraform_remote_state.pcf.outputs.deployment_prefix}-${var.clusters[count.index]}-pool"

  # Only legacy health HTTP health checks are 
  # supported for now. Wait until this is fixed. 
  #
  # health_checks = [
  #   "${element(google_compute_health_check.k8s.*.name, count.index)}",
  # ]

  instances = "${split(",", lookup(var.cluster_instances, var.clusters[count.index]))}"
}

// PKS Kubernetes API tcp forwarding rule
resource "google_compute_forwarding_rule" "k8s" {
  count = "${length(var.clusters)}"
  name  = "${data.terraform_remote_state.pcf.outputs.deployment_prefix}-${var.clusters[count.index]}-forward-rule"

  target = "${element(google_compute_target_pool.k8s.*.self_link, count.index)}"

  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${element(google_compute_address.k8s.*.address, count.index)}"
}

// Allow access to PKS resourcecs
resource "google_compute_firewall" "k8s" {
  count = "${length(var.clusters)}"
  name  = "${data.terraform_remote_state.pcf.outputs.deployment_prefix}-${var.clusters[count.index]}-allow-k8s"

  network = "${data.terraform_remote_state.pcf.outputs.vpc_network_name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags = ["service-instance-${lookup(var.cluster_ids, var.clusters[count.index])}-master"]
}
