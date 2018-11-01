#
# Bootstrap an base environment named "inceptor"
#

locals {
  bootstrap_state_prefix = "${var.vpc_name}-bootstrap"
}

module "bootstrap" {
  source = "../../../../lib/inceptor/modules/bootstrap-automation/gcp"

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

  # DNS Name for VPC will be 'cf.tfacc.pcfs.io'
  vpc_dns_zone = "${var.vpc_dns_zone}"

  vpc_internal_dns_zones = ["${var.vpc_name}.local"]

  # Name of parent zone 'tfacc.pcfs.io' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "${var.vpc_parent_dns_zone_name}"

  # Path to save all ssh key files
  ssh_key_file_path = "${var.ssh_key_file_path == "" ? path.module : var.ssh_key_file_path}"

  # Bastion configuration
  bastion_host_name = "${var.bastion_host_name}"

  bastion_instance_type = "n1-standard-2"

  bastion_admin_ssh_port = "${var.bastion_admin_ssh_port}"
  bastion_admin_user     = "${var.bastion_admin_user}"

  bastion_allow_public_ssh = "${
    var.bastion_allow_public_ssh == ""
      ? var.bastion_setup_vpn == "true" 
        ? "false"
        : "true"
      : var.bastion_allow_public_ssh }"

  deploy_jumpbox         = "${var.deploy_jumpbox}"
  jumpbox_data_disk_size = "${var.jumpbox_data_disk_size}"

  vpn_server_port = "${
    var.bastion_setup_vpn == "true" 
      ? var.bastion_vpn_port
      : "" }"

  vpn_protocol = "${var.bastion_vpn_protocol}"
  vpn_network  = "${var.bastion_vpn_network}"

  #
  # Concourse Settings
  #
  concourse_admin_password = "${random_string.concourse-admin-password.result}"

  concourse_server_port = "8080"

  #
  # SMTP Settings
  #
  smtp_relay_host = "${var.smtp_relay_host}"

  smtp_relay_port    = "${var.smtp_relay_port}"
  smtp_relay_api_key = "${var.smtp_relay_api_key}"

  #
  # Bootstrap pipeline
  #
  bootstrap_pipeline_file = "${path.module}/../pipeline/pipeline.yml"

  # Email to send pipeline otifications to
  notification_email = "${var.notification_email}"

  # Path to cloud-inceptor scripts 
  # in pipeline automation resource
  pipeline_automation_path = "automation/lib/inceptor"

  # This is a YML file snippet. It is important not to include
  # the '---' header as that is created via the bastion module 
  # when the complete params file is rendered.
  bootstrap_pipeline_vars = <<PIPELINE_VARS
trace: ${var.trace}

google_project: ${var.gcp_project}
google_region: ${var.gcp_region}

google_credentials_json: |
  ${indent(2, file(var.gcp_credentials))}

bootstrap_state_bucket: ${var.terraform_state_bucket}
bootstrap_state_prefix: ${local.bootstrap_state_prefix}

automation_pipelines_repo: ${var.automation_pipelines_repo}
automation_pipelines_branch: ${var.automation_pipelines_branch}

vpc_name: ${var.vpc_name}
vpc_dns_zone: ${var.vpc_dns_zone}

environments: '${join(" ", var.pcf_environments)}'
products: '${var.products}'

unpause_install_pipeline: ${var.autostart_deployment_pipelines}

opsman_admin_username: admin
opsman_admin_password: ${random_string.opsman-admin-password.result}

set_start_stop_schedule: ${var.pcf_stop_at != "0" ? "true" : "false"}

PIPELINE_VARS
}
