#
# Bootstrap an base environment named "inceptor"
#

module "bootstrap" {
  source = "../../../../lib/inceptor/modules/bootstrap/gcp"

  #
  # Company information used in certificate creation
  #
  company_name = "${var.company_name}"

  organization_name = "${var.organization_name}"

  locality = "${var.locality}"

  province = "${var.province}"

  country = "${var.country}"

  #
  # VPC details
  #
  region = "${var.gcp_region}"

  vpc_name = "${var.vpc_name}"

  vpc_cidr = "192.168.0.0/16"

  vpc_subnet_bits = "8"

  vpc_subnet_start = "0"

  max_azs = "${var.max_azs}"

  bastion_host_name = "vpn"

  bastion_instance_type = "n1-standard-2"

  deploy_jumpbox = "${var.deploy_jumpbox}"

  jumpbox_data_disk_size = "${var.jumpbox_data_disk_size}"

  # DNS Name for VPC will be 'cf.tfacc.pcfs.io'
  vpc_dns_zone = "${var.vpc_dns_zone}"

  # Name of parent zone 'tfacc.pcfs.io' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "${var.vpc_parent_dns_zone_name}"

  # Path to save all ssh key files
  ssh_key_file_path = "${var.ssh_key_file_path == "" ? path.module : var.ssh_key_file_path}"

  #
  # VPN Settings
  #
  vpn_server_port = "2295"

  vpn_protocol = "udp"

  vpn_network = "192.168.111.0/24"

  #
  # Concourse Settings
  #
  concourse_admin_password = "${random_string.concourse-admin-password.result}"

  #
  # Bootstrap pipeline
  #
  bootstrap_pipeline_file = "${path.module}/../pipeline/pipeline.yml"

  # This is a YML file snippet. It is important not to include
  # the '---' header as that is created via the bastion module 
  # when the complete params file is rendered.
  bootstrap_pipeline_vars = <<PIPELINE_VARS
google_project: ${var.gcp_project}
google_region: ${var.gcp_region}

google_credentials_json: |
  ${indent(2, file(var.gcp_credentials))}

bootstrap_state_bucket: ${var.terraform_state_bucket}
bootstrap_state_prefix: ${var.bootstrap_state_prefix}

automation_pipelines_repo: ${var.automation_pipelines_repo}
automation_pipelines_branch: ${var.automation_pipelines_branch}

pcf_pas_runtime_type: srt

pivnet_token: "${var.pivnet_token}"

opsman_domain_or_ip_address: opsman.pas.${var.vpc_dns_zone}
opsman_client_id:
opsman_client_secret:
opsman_admin_username: admin
opsman_admin_password: ${random_string.opsman-admin-password.result}

unpause_install_pipeline: true

product: '${var.products}'

set_start_stop_schedule: ${var.pcf_stop_at != "0" ? "true" : "false"}

PIPELINE_VARS
}
