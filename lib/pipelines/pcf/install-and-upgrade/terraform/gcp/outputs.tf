// Core Project Output

output "region" {
  value = "${var.gcp_region}"
}

output "azs" {
  value = "${var.gcp_zone_1},${var.gcp_zone_2},${var.gcp_zone_3}"
}

output "deployment_prefix" {
  value = "${var.prefix}-vms"
}

// DNS Output

output "ops_manager_dns" {
  value = "${google_dns_record_set.ops-manager-dns.name}"
}

output "pcf_ert_domain" {
  value = "${local.pas_domain}"
}

output "system_domain" {
  value = "${local.system_domain}"
}

output "apps_domain" {
  value = "${local.apps_domain}"
}

output "tcp_domain" {
  value = "tcp.${local.pas_domain}"
}

output "env_dns_zone_name_servers" {
  value = "${google_dns_managed_zone.env_dns_zone.name_servers}"
}

// Network Output

output "vpc_network_name" {
  value = "${google_compute_network.pcf-virt-net.name}"
}

output "ops_manager_gateway" {
  value = "${google_compute_subnetwork.subnet-ops-manager.gateway_address}"
}

output "ops_manager_cidr" {
  value = "${google_compute_subnetwork.subnet-ops-manager.ip_cidr_range}"
}

output "ops_manager_subnet" {
  value = "${google_compute_subnetwork.subnet-ops-manager.name}"
}

output "ert_gateway" {
  value = "${google_compute_subnetwork.subnet-ert.gateway_address}"
}

output "ert_cidr" {
  value = "${google_compute_subnetwork.subnet-ert.ip_cidr_range}"
}

output "ert_subnet" {
  value = "${google_compute_subnetwork.subnet-ert.name}"
}

output "svc_net_1_gateway" {
  value = "${google_compute_subnetwork.subnet-services-1.gateway_address}"
}

output "svc_net_1_cidr" {
  value = "${google_compute_subnetwork.subnet-services-1.ip_cidr_range}"
}

output "svc_net_1_subnet" {
  value = "${google_compute_subnetwork.subnet-services-1.name}"
}

output "dynamic_svc_net_1_gateway" {
  value = "${google_compute_subnetwork.subnet-dynamic-services-1.gateway_address}"
}

output "dynamic_svc_net_1_cidr" {
  value = "${google_compute_subnetwork.subnet-dynamic-services-1.ip_cidr_range}"
}

output "dynamic_svc_net_1_subnet" {
  value = "${google_compute_subnetwork.subnet-dynamic-services-1.name}"
}

// Http Load Balancer Output

output "http_lb_backend_name" {
  value = "${google_compute_backend_service.ert_http_lb_backend_service.name}"
}

output "tcp_router_pool" {
  value = "${google_compute_target_pool.cf-tcp.name}"
}

// Cloud Storage Bucket Output

output "buildpacks_bucket" {
  value = "${google_storage_bucket.buildpacks.name}"
}

output "droplets_bucket" {
  value = "${google_storage_bucket.droplets.name}"
}

output "packages_bucket" {
  value = "${google_storage_bucket.packages.name}"
}

output "resources_bucket" {
  value = "${google_storage_bucket.resources.name}"
}

output "director_blobstore_bucket" {
  value = "${google_storage_bucket.director.name}"
}

output "pub_ip_global_pcf" {
  value = "${google_compute_global_address.pcf.address}"
}

output "pub_ip_ssh_and_doppler" {
  value = "${google_compute_address.cf-ssh.address}"
}

output "pub_ip_ssh_tcp_lb" {
  value = "${google_compute_address.cf-tcp.address}"
}

output "db_host" {
  value = "${google_sql_database_instance.master.ip_address.0.ip_address}"
}

output "pks_api_lb_name" {
  value = "tcp:${google_compute_target_pool.pks-api.name}"
}

// Certificates

output "saml_certificate" {
  value = "${length(var.pcf_saml_ssl_cert) > 0 ? var.pcf_saml_ssl_cert : tls_locally_signed_cert.saml-san.cert_pem}"
}

output "saml_certificate_key" {
  value = "${length(var.pcf_saml_ssl_key) > 0 ? var.pcf_saml_ssl_key : tls_private_key.saml-san.private_key_pem}"
}

output "ert_certificate" {
  value = "${google_compute_ssl_certificate.lb-cert.certificate}"
}

output "ert_certificate_key" {
  value = "${google_compute_ssl_certificate.lb-cert.private_key}"
}

output "pks_certificate" {
  value = "${google_compute_ssl_certificate.lb-cert.certificate}"
}

output "pks_certificate_key" {
  value = "${google_compute_ssl_certificate.lb-cert.private_key}"
}
