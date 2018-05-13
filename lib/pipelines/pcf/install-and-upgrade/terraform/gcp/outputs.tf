// Core Project Output

output "company_name" {
  value = "${data.terraform_remote_state.bootstrap.company_name}"
}

output "deployment_prefix" {
  value = "${var.prefix}-vms"
}

output "region" {
  value = "${var.gcp_region}"
}

output "singleton_availability_zone" {
  value = "${var.gcp_zone_1}"
}

output "availability_zones" {
  value = "${var.gcp_zone_1},${var.gcp_zone_2},${var.gcp_zone_3}"
}

// DNS Output

output "env_dns_zone_name_servers" {
  value = "${google_dns_managed_zone.env_dns_zone.name_servers}"
}

output "pcf_env_domain" {
  value = "${local.env_domain}"
}

output "system_domain" {
  value = "${local.system_domain}"
}

output "tcp_domain" {
  value = "tcp.${local.env_domain}"
}

output "apps_domain" {
  value = "${local.apps_domain}"
}

output "ops_manager_dns" {
  value = "${
    substr(
      google_dns_record_set.ops-manager-dns.name, 0, 
      length(google_dns_record_set.ops-manager-dns.name)-1)}"
}

output "pks_url" {
  value = "${
    substr(
      google_dns_record_set.pks.name, 0, 
      length(google_dns_record_set.pks.name)-1)}"
}

output "harbor_registry_fqdn" {
  value = "${
    substr(
      google_dns_record_set.harbor.name, 0, 
      length(google_dns_record_set.harbor.name)-1)}"
}

// Network Output

output "pcf_networks" {
  value = <<-JSON
  
  JSON
}

#   --arg infra_network_name "infrastructure" \
#   --arg infra_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-infrastructure-${GCP_REGION}/${GCP_REGION}" \
#   --arg infra_network_cidr "192.168.101.0/26" \
#   --arg infra_reserved_ip_ranges "192.168.101.1-192.168.101.9" \
#   --arg infra_dns "192.168.101.1,8.8.8.8" \
#   --arg infra_gateway "192.168.101.1" \
#   --arg infra_availability_zones "$AVAILABILITY_ZONES" \
#   --arg deployment_network_name "ert" \
#   --arg deployment_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-ert-${GCP_REGION}/${GCP_REGION}" \
#   --arg deployment_network_cidr "192.168.16.0/22" \
#   --arg deployment_reserved_ip_ranges "192.168.16.1-192.168.16.9" \
#   --arg deployment_dns "192.168.16.1,8.8.8.8" \
#   --arg deployment_gateway "192.168.16.1" \
#   --arg deployment_availability_zones "$AVAILABILITY_ZONES" \
#   --arg services_network_name "services-1" \
#   --arg services_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-services-1-${GCP_REGION}/${GCP_REGION}" \
#   --arg services_network_cidr "192.168.20.0/22" \
#   --arg services_reserved_ip_ranges "192.168.20.1-192.168.20.9" \
#   --arg services_dns "192.168.20.1,8.8.8.8" \
#   --arg services_gateway "192.168.20.1" \
#   --arg services_availability_zones "$AVAILABILITY_ZONES" \
#   --arg dynamic_services_network_name "dynamic-services-1" \
#   --arg dynamic_services_iaas_network "${GCP_RESOURCE_PREFIX}-virt-net/${GCP_RESOURCE_PREFIX}-subnet-dynamic-services-1-${GCP_REGION}/${GCP_REGION}" \
#   --arg dynamic_services_network_cidr "192.168.24.0/22" \
#   --arg dynamic_services_reserved_ip_ranges "192.168.24.1-192.168.24.9" \
#   --arg dynamic_services_dns "192.168.24.1,8.8.8.8" \
#   --arg dynamic_services_gateway "192.168.24.1" \
#   --arg dynamic_services_availability_zones "$AVAILABILITY_ZONES" \

output "vpc_network_name" {
  value = "${google_compute_network.pcf.name}"
}

// Public IPs

output "pub_ip_global_pcf" {
  value = "${google_compute_global_address.pcf.address}"
}

output "pub_ip_ssh_and_doppler" {
  value = "${google_compute_address.cf-ssh.address}"
}

output "pub_ip_ssh_tcp_lb" {
  value = "${google_compute_address.cf-tcp.address}"
}

// Load balancer pools

output "pas_http_lb_name" {
  value = "http:${google_compute_backend_service.ert_http_lb_backend_service.name}"
}

output "pas_tcp_lb_name" {
  value = "tcp:${google_compute_target_pool.cf-tcp.name}"
}

output "pas_ssh_lb_name" {
  value = "tcp:${google_compute_target_pool.cf-ssh.name}"
}

output "pas_doppler_lb_name" {
  value = "tcp:${google_compute_target_pool.cf-gorouter.name}"
}

output "pks_lb_name" {
  value = "tcp:${google_compute_target_pool.pks.name}"
}

output "harbor_lb_name" {
  value = "tcp:${google_compute_target_pool.harbor.name}"
}

output "tcp_routing_reservable_ports" {
  value = "${google_compute_forwarding_rule.cf-tcp.port_range}"
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

output "db_host" {
  value = "${google_sql_database_instance.master.ip_address.0.ip_address}"
}

// Certificates

output "ca_certs" {
  value = "${data.terraform_remote_state.bootstrap.root_ca_cert}"
}

output "saml_cert" {
  value = "${length(var.pcf_saml_ssl_cert) > 0 ? var.pcf_saml_ssl_cert : tls_locally_signed_cert.saml-san.cert_pem}"
}

output "saml_cert_key" {
  value = "${length(var.pcf_saml_ssl_key) > 0 ? var.pcf_saml_ssl_key : tls_private_key.saml-san.private_key_pem}"
}

output "ert_cert" {
  value = "${google_compute_ssl_certificate.lb-cert.certificate}"
}

output "ert_cert_key" {
  value = "${google_compute_ssl_certificate.lb-cert.private_key}"
}

output "pks_cert" {
  value = "${google_compute_ssl_certificate.lb-cert.certificate}"
}

output "pks_cert_key" {
  value = "${google_compute_ssl_certificate.lb-cert.private_key}"
}

output "harbor_registry_cert" {
  value = "${google_compute_ssl_certificate.lb-cert.certificate}"
}

output "harbor_registry_cert_key" {
  value = "${google_compute_ssl_certificate.lb-cert.private_key}"
}
