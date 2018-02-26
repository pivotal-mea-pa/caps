#
# Bootstrap an base environment named "inceptor"
#

module "bootstrap" {
  source = "github.com/appbricks/cloud-inceptor//modules/bootstrap/gcp"

  #
  # Company information used in certificate creation
  #
  company_name = "Pivotal Services"

  organization_name = "PSO EMEA"

  locality = "Dubai"

  province = "Dubayy"

  country = "AE"

  #
  # VPC details
  #
  region = "europe-west3"

  vpc_name = "cf1-tfacc"

  vpc_cidr = "192.168.0.0/16"

  vpc_subnet_bits = "8"

  vpc_subnet_start = "0"

  max_azs = "1"

  bastion_host_name = "vpn"

  # DNS Name for VPC will be 'cf.tfacc.pcfs.io'
  vpc_dns_zone = "cf1.tfacc.pcfs.io"

  # Name of parent zone 'tfacc.pcfs.io' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "tfacc-pcfs-io"

  #
  # VPN Settings
  #
  vpn_server_port = "2295"

  vpn_protocol = "udp"

  vpn_network = "192.168.111.0/24"

  #
  # Bootstrap pipeline
  #
  # bootstrap_pipeline_file = "../../../pipelines/bootstrap-hello-world/pipeline.yml"

  bootstrap_pipeline_vars = ""
}

#
# Backend state
#
terraform {
  backend "gcs" {
    bucket = "appbricks-euw3-tf-states"
    prefix = "tfacc/cf1-bs"
  }
}

#
# Network resource attributes
#
output "dmz_network" {
  value = "${module.bootstrap.dmz_network}"
}

output "dmz_subnetwork" {
  value = "${module.bootstrap.dmz_subnetwork}"
}

output "engineering_network" {
  value = "${module.bootstrap.engineering_network}"
}

output "engineering_subnetwork" {
  value = "${module.bootstrap.engineering_subnetwork}"
}

output "vpc_dns_zone" {
  value = "${module.bootstrap.vpc_dns_zone}"
}

#
# Bastion resource attributes
#
output "bastion_fqdn" {
  value = "${module.bootstrap.bastion_fqdn}"
}

output "bastion_admin_fqdn" {
  value = "${module.bootstrap.bastion_admin_fqdn}"
}

output "vpn_admin_password" {
  value = "${module.bootstrap.vpn_admin_password}"
}

output "default_openssh_public_key" {
  value = "${module.bootstrap.default_openssh_public_key}"
}

output "concourse_admin_password" {
  value = "${module.bootstrap.concourse_admin_password}"
}
