// Core Project Output

output "company_name" {
  value = "${data.terraform_remote_state.bootstrap.company_name}"
}

output "deployment_prefix" {
  value = "${local.prefix}"
}

#
# vCenter IaaS Environment
#

output "vsphere_server" {
  value = "${data.terraform_remote_state.bootstrap.vsphere_server}"
}

output "vsphere_user" {
  value = "${data.terraform_remote_state.bootstrap.vsphere_user}"
}

output "vsphere_password" {
  value = "${data.terraform_remote_state.bootstrap.vsphere_password}"
}

output "vsphere_allow_unverified_ssl" {
  value = "${data.terraform_remote_state.bootstrap.vsphere_allow_unverified_ssl}"
}

output "vcenter_datacenter" {
  value = "${data.terraform_remote_state.bootstrap.vcenter_datacenter}"
}

output "vcenter_templates_path" {
  value = "${local.templates_path}"
}

output "vcenter_vms_path" {
  value = "${local.vms_path}"
}

output "vcenter_disks_path" {
  value = "${local.disks_path}"
}

# Comma separated list of ephemeral data stores
output "vcenter_ephemeral_datastores" {
  value = "${data.terraform_remote_state.bootstrap.vcenter_ephemeral_datastores}"
}

# Comma separated list of persistent data stores
output "vcenter_persistant_datastores" {
  value = "${data.terraform_remote_state.bootstrap.vcenter_persistant_datastores}"
}

# Map of availability zones defined
# as cluster => resource pool pairs.
output "availability_zone_config" {
  value = <<JSON
{
  "azs": ${jsonencode(data.external.pcf-availability-zones.*.result)}
}
JSON
}

output "availability_zones" {
  value = "${join(",", local.az_names)}"
}

output "singleton_availability_zone" {
  value = "${local.az_names[0]}"
}

# PCF Networks to be configured on
# Ops Manager
output "pcf_networks" {
  value = <<JSON
{
  "pcf_networks": ${jsonencode(data.external.pcf-networks.*.result)}
}
JSON
}

# NTP

output "ntp_servers" {
  value = "${data.terraform_remote_state.bootstrap.pcf_network_ntp}"
}

# Static IPs

output "ha_proxy_static_ip" {
  value = "${local.ha_proxy_ip}"
}

output "router_static_ips" {
  value = "${lookup(local.pcf_static_ips, "pas_router_ips", "")}"
}

output "tcp_router_static_ips" {
  value = "${lookup(local.pcf_static_ips, "pas_tcp_router_ips", "")}"
}

output "diego_brain_static_ips" {
  value = "${lookup(local.pcf_static_ips, "pas_diego_brains_ips", "")}"
}

# DNS

output "env_dns_zone_name_servers" {
  value = "${data.terraform_remote_state.bootstrap.pcf_network_dns}"
}

output "env_domain" {
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

output "pks_url" {
  value = "pks.${local.env_domain}"
}

output "harbor_registry_fqdn" {
  value = "harbor.${local.env_domain}"
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
  value = "${local.ert_ssl_cert}"
}

output "ert_cert_key" {
  value = "${local.ert_ssl_key}"
}

output "pks_cert" {
  value = "${local.ert_ssl_cert}"
}

output "pks_cert_key" {
  value = "${local.ert_ssl_key}"
}

output "harbor_registry_cert" {
  value = "${local.ert_ssl_cert}"
}

output "harbor_registry_cert_key" {
  value = "${local.ert_ssl_key}"
}
