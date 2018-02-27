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
  region = "${var.gcp_region}"

  vpc_name = "${var.vpc_name}"

  vpc_cidr = "192.168.0.0/16"

  vpc_subnet_bits = "8"

  vpc_subnet_start = "0"

  max_azs = "1"

  bastion_host_name = "vpn"

  # DNS Name for VPC will be 'cf.tfacc.pcfs.io'
  vpc_dns_zone = "${var.vpc_dns_zone}"

  # Name of parent zone 'tfacc.pcfs.io' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "${var.vpc_parent_dns_zone_name}"

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
