#
# Bootstrap an base environment named "inceptor"
#

locals {
  bootstrap_state_prefix = "${var.vpc_name}-bootstrap"
  has_dmz_network        = "${length(var.dmz_network) > 0}"

  bastion_admin_name = "${length(var.bastion_host_name) == 0 
    ? var.vpc_name 
    : var.bastion_host_name}.${var.vpc_dns_zone}"

  bastion_admin_ip = "${length(var.bastion_admin_ip) > 0 
    ? var.bastion_admin_ip
    : cidrhost(var.admin_network_cidr, 31)}"

  bastion_dmz_ip = "${length(var.bastion_dmz_ip) > 0
    ? var.bastion_dmz_ip
    : local.has_dmz_network 
      ? cidrhost(local.has_dmz_network ? var.dmz_network_cidr : "0.0.0.0/0", 31) 
      : local.bastion_admin_ip}"
}

module "bootstrap" {
  source = "../../../../lib/inceptor/modules/bootstrap-automation/vsphere"

  #
  # Company information used in certificate creation
  #
  company_name = "${var.company_name}"

  organization_name = "${var.organization_name}"

  locality = "${var.locality}"

  province = "${var.province}"

  country = "${var.country}"

  #
  # VMware IaaS configuration
  #
  datacenter = "${var.vcenter_datacenter}"

  clusters             = ["${split(",", var.vcenter_clusters)}"]
  ephemeral_datastore  = "${element(split(",", var.vcenter_ephemeral_datastores), 0)}"
  persistent_datastore = "${element(split(",", var.vcenter_persistant_datastores), 0)}"

  dmz_network         = "${var.dmz_network}"
  dmz_network_cidr    = "${var.dmz_network_cidr}"
  dmz_network_gateway = "${var.dmz_network_gateway}"

  admin_network         = "${var.admin_network}"
  admin_network_cidr    = "${var.admin_network_cidr}"
  admin_network_gateway = "${var.admin_network_gateway}"

  # VPC details
  vpc_name = "${var.vpc_name}"
  vpc_cidr = "${var.vpc_cidr}"

  # DNS zone for VPC.
  vpc_dns_zone = "${var.vpc_dns_zone}"

  # Internal DNS zones within VPC
  vpc_internal_dns_zones = ["${var.vpc_dns_zone}", "${var.vpc_name}.local"]

  vpc_internal_dns_records = [
    "${var.vpc_dns_zone}:${local.has_dmz_network ? local.bastion_dmz_ip : local.bastion_admin_ip}",
    "${local.bastion_admin_name}:${local.bastion_admin_ip}",
  ]

  # Path to save all ssh key files
  ssh_key_file_path = "${var.ssh_key_file_path == "" ? path.module : var.ssh_key_file_path}"

  # Bastion configuration
  bastion_host_name = "${var.bastion_host_name}"
  bastion_dns       = "${var.bastion_dns}"

  bastion_instance_memory = "${var.bastion_instance_memory}"
  bastion_instance_cpus   = "${var.bastion_instance_cpus}"
  bastion_root_disk_size  = "${var.bastion_root_disk_size}"
  bastion_data_disk_size  = "${var.bastion_data_disk_size}"

  bastion_admin_ssh_port = "${var.bastion_admin_ssh_port}"
  bastion_admin_user     = "${var.bastion_admin_user}"

  bastion_allow_public_ssh = "${
    var.bastion_allow_public_ssh == ""
      ? var.bastion_setup_vpn == "true" 
        ? "false"
        : "true"
      : var.bastion_allow_public_ssh }"

  bastion_dmz_ip   = "${local.bastion_dmz_ip}"
  bastion_admin_ip = "${local.bastion_admin_ip}"

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

  concourse_server_port = "${local.bastion_dmz_ip == local.bastion_admin_ip 
    ? format("%s:8080", local.bastion_admin_ip) 
    : "8080"}"

  #
  # SMTP Settings
  #
  smtp_relay_host = "${var.smtp_relay_host}"

  smtp_relay_port    = "${var.smtp_relay_port}"
  smtp_relay_api_key = "${var.smtp_relay_api_key}"

  #
  # Bootstrap pipeline
  #
  # bootstrap_pipeline_file = "${path.module}/../pipeline/pipeline.yml"
  bootstrap_pipeline_file = "${path.module}/../pipeline/pipeline.yml"

  # Email to send pipeline notifications to
  notification_email = "${var.notification_email}"

  # Path to cloud-inceptor scripts 
  # in pipeline automation resource
  pipeline_automation_path = "automation/lib/inceptor"

  # This is a YML file snippet. It is important not to include
  # the '---' header as that is created via the bastion module 
  # when the complete params file is rendered.
  bootstrap_pipeline_vars = <<PIPELINE_VARS
trace: ${var.trace}

vsphere_server: '${var.vsphere_server}'
vsphere_user: '${var.vsphere_user}'
vsphere_password: '${var.vsphere_password}'
vsphere_allow_unverified_ssl: ${var.vsphere_allow_unverified_ssl}

vcenter_datacenter: '${var.vcenter_datacenter}'
vcenter_clusters: '${var.vcenter_clusters}'
vcenter_ephemeral_datastores: '${var.vcenter_ephemeral_datastores}'
vcenter_persistant_datastores: '${var.vcenter_persistant_datastores}'

vpc_dns_zone: '${var.vpc_dns_zone}'

s3_access_key_id: '${var.s3_access_key_id}'
s3_secret_access_key: '${var.s3_secret_access_key}'
s3_default_region: '${var.s3_default_region}'

bootstrap_state_s3_endpoint: '${var.terraform_state_s3_endpoint}'
bootstrap_state_bucket: '${var.terraform_state_bucket}'
bootstrap_state_prefix: '${local.bootstrap_state_prefix}'

automation_pipelines_repo: '${var.automation_pipelines_repo}'
automation_pipelines_branch: '${var.automation_pipelines_branch}'

env_config_repo: '${var.env_config_repo}'
env_config_repo_branch: '${var.env_config_repo_branch}'
env_config_path: '${var.env_config_path}'

environments: '${join(" ", var.pcf_environments)}'

unpause_deployment_pipeline: ${var.unpause_deployment_pipeline}
set_start_stop_schedule: ${var.set_start_stop_schedule}

PIPELINE_VARS
}
