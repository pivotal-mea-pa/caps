#
# Local Variables
#

locals {
  prefix = "${data.terraform_remote_state.bootstrap.vpc_name}-${var.environment}"

  vcenter_datacenter = "${data.terraform_remote_state.bootstrap.vcenter_datacenter}"

  opsman_vcenter_config = "${data.terraform_remote_state.bootstrap.pcf_opsman_vcenter_config[var.environment]}"

  opsman_vcenter_az              = "${lookup(local.opsman_vcenter_config, "availability_zone")}"
  opsman_vcenter_datastore       = "${lookup(local.opsman_vcenter_config, "datastore")}"
  opsman_vcenter_network         = "${lookup(local.opsman_vcenter_config, "network")}"
  opsman_vcenter_network_cidr    = "${lookup(local.opsman_vcenter_config, "network_cidr")}"
  opsman_vcenter_network_gateway = "${lookup(local.opsman_vcenter_config, "network_gateway")}"
  opsman_vcenter_ip              = "${lookup(local.opsman_vcenter_config, "ip")}"

  opsman_az                    = "${data.terraform_remote_state.bootstrap.availability_zones[local.opsman_vcenter_az]}"
  opsman_cluster_name          = "${local.opsman_az["cluster"]}"
  opsman_cluster_resource_pool = "${lookup(local.opsman_az, "resource_pool", "")}"
}

#
# External Variables
#

variable "environment" {}

# Network

variable "system_domain_prefix" {}
variable "apps_domain_prefix" {}

# Certificates

variable "pcf_ert_ssl_cert" {
  default = ""
}

variable "pcf_ert_ssl_key" {
  default = ""
}

variable "pcf_saml_ssl_cert" {
  default = ""
}

variable "pcf_saml_ssl_key" {
  default = ""
}
