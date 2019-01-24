#
# Cloud pre-configuration for PKS
#

// PKS external IP
resource "google_compute_address" "pks" {
  name = "${local.prefix}-pks"
}

// PKS API DNS
resource "google_dns_record_set" "pks" {
  name         = "pks.${local.env_domain}."
  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  type = "A"
  ttl  = 300

  rrdatas = ["${google_compute_address.pks.address}"]
}

// PKS target pool
resource "google_compute_target_pool" "pks" {
  name = "${local.prefix}-pks"
}

// PKS API tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-api" {
  name        = "${local.prefix}-pks-api-lb"
  target      = "${google_compute_target_pool.pks.self_link}"
  port_range  = "9021"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.pks.address}"
}

// PKS UAA tcp forwarding rule
resource "google_compute_forwarding_rule" "pks-uaa" {
  name        = "${local.prefix}-pks-uaa-lb"
  target      = "${google_compute_target_pool.pks.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.pks.address}"
}

// Allow access to PKS resourcecs
resource "google_compute_firewall" "pks" {
  name    = "${local.prefix}-allow-pks"
  network = "${google_compute_network.pcf.name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  allow {
    protocol = "tcp"
    ports    = ["9021"]
  }

  target_tags = ["${google_compute_target_pool.pks.name}"]
}

// PKS Master Node services account

resource "google_service_account" "pks-master" {
  account_id   = "${replace(local.prefix, "-", "")}pksmaster"
  display_name = "PKS Master Node Service Account for ${local.prefix}"
}

resource "google_project_iam_member" "pks-master-iam-computeInstanceAdmin" {
  project = "${data.terraform_remote_state.bootstrap.gcp_project}"
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.pks-master.email}"
}

resource "google_project_iam_member" "pks-master-iam-computeNetworkAdmin" {
  project = "${data.terraform_remote_state.bootstrap.gcp_project}"
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.pks-master.email}"
}

resource "google_project_iam_member" "pks-master-iam-computeSecurityAdmin" {
  project = "${data.terraform_remote_state.bootstrap.gcp_project}"
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.pks-master.email}"
}

resource "google_project_iam_member" "pks-master-iam-computeStorageAdmin" {
  project = "${data.terraform_remote_state.bootstrap.gcp_project}"
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.pks-master.email}"
}

resource "google_project_iam_member" "pks-master-iam-computeViewer" {
  project = "${data.terraform_remote_state.bootstrap.gcp_project}"
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.pks-master.email}"
}

resource "google_project_iam_member" "pks-master-iam-serviceAccountUser" {
  project = "${data.terraform_remote_state.bootstrap.gcp_project}"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.pks-master.email}"
}

// PKS Worker Node services account

resource "google_service_account" "pks-worker" {
  account_id   = "${replace(local.prefix, "-", "")}pksworker"
  display_name = "PKS Worker Node Service Account for ${local.prefix}"
}

resource "google_project_iam_member" "pks-worker-iam-computeViewer" {
  project = "${data.terraform_remote_state.bootstrap.gcp_project}"
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.pks-worker.email}"
}
