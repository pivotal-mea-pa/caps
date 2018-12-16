#
# Automation bootstrap
#

variable "trace" {
  default = "true"
}

variable "unpause_deployment_pipeline" {
  default = "true"
}

variable "set_start_stop_schedule" {
  default = "false"
}

#
# GCP credentials
#

variable "gcp_credentials" {
  type = "string"
}

variable "gcp_region" {
  type = "string"
}

variable "gcp_storage_access_key" {
  type = "string"
}

variable "gcp_storage_secret_key" {
  type = "string"
}

#
# Terraform state attributes
#

variable "terraform_state_bucket" {
  type = "string"
}

#
# Certificate Subject data for certificate creation
#
variable "company_name" {
  default = "Pivotal Services"
}

variable "organization_name" {
  default = "PSO EMEA"
}

variable "locality" {
  default = "Dubai"
}

variable "province" {
  default = "Dubayy"
}

variable "country" {
  default = "AE"
}

#
# VPC configuration
#

# This value should match the name of your caps init environment.
# It is set when you run "caps-init first time and should not be 
# changed.
variable "vpc_name" {
  type = "string"
}

variable "max_azs" {
  default = "1"
}

variable "vpc_dns_zone" {
  type = "string"
}

variable "vpc_parent_dns_zone_name" {
  type = "string"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "vpc_subnet_bits" {
  default = "8"
}

variable "vpc_subnet_start" {
  default = "0"
}

#
# Bastion inception instance variables
#
variable "bastion_instance_type" {
  default = "n1-standard-2"
}

variable "bastion_data_disk_size" {
  default = "250"
}

#
# Bastion access configuration
#
variable "bastion_host_name" {
  default = "bastion"
}

variable "bastion_admin_ssh_port" {
  default = "22"
}

# This needs to be a name other than 'root' or 'admin' otherwise 
# the user setup on the bastion will fail and you will be unable 
# to login to the instance.
variable "bastion_admin_user" {
  type = "string"
}

variable "bastion_setup_vpn" {
  type = "string"
}

variable "bastion_vpn_port" {
  default = "2295"
}

variable "bastion_vpn_protocol" {
  default = "udp"
}

variable "bastion_vpn_network" {
  default = "192.168.111.0/24"
}

variable "bastion_allow_public_ssh" {
  type = "string"
}

#
# VPC SMTP Server Relay
#

variable "smtp_relay_host" {
  default = ""
}

variable "smtp_relay_port" {
  default = ""
}

variable "smtp_relay_api_key" {
  default = ""
}

# Email to send notifications to
variable "notification_email" {
  type = "string"
}

#
# Local file path to write SSH private key for bastion instance
#
variable "ssh_key_file_path" {
  default = ""
}

#
# Jumpbox
#

variable "deploy_jumpbox" {
  default = "false"
}

variable "jumpbox_data_disk_size" {
  default = "160"
}

#
# Concourse Automation common attributes
#

#
# Cloud Automation Pipelines (CAPs) repository
#

variable "automation_pipelines_repo" {
  default = "https://github.com/mevansam/caps.git"
}

variable "automation_pipelines_branch" {
  default = "master"
}

#
# Environment configuration repository
#

variable "env_config_repo" {
  default = "https://github.com/mevansam/caps.git"
}

variable "env_config_repo_branch" {
  default = "master"
}

variable "env_config_path" {
  default = "deployments/pcf/google/config"
}

#
# Automation extensions git repository
#

variable "automation_extensions_repo" {
  default = "https://github.com/mevansam/caps.git"
}

variable "automation_extensions_repo_branch" {
  default = "master"
}

# Path to terraform template overrides in the 'automation extensions' 
# repository for creating PCF PAS infrastructure.
variable "pcf_terraform_templates_path" {
  default = "-"
}

# Path to json template overrides in the 'automation extensions' 
# repository for configuring PCF tiles. This folder should have 
# folders named by the tile name as provided in the 'products' 
# variable below.
variable "pcf_tile_templates_path" {
  default = "-"
}

# The list of PCF environments to deploy.

#export TF_VAR_pcf_environments='["sandbox"]'
variable "pcf_environments" {
  type    = "list"
  default = ["sandbox"]
}

# The PCF Networks to create. The order in which subnets should 
# be configured are provided via the 'subnet_config_order' key.
# If you need to add subnets always add to the end of this list.
# Otherwise any reordering will result in networks being recreated 
# and may have undesired outcomes.

#export TF_VAR_pcf_networks='{
#  sandbox = {
#    service_networks    = "services,dynamic-services"
#    subnet_config_order = "infrastructure,pas-1,services-1,dynamic-services-1,monitoring"
#  }
#}'
variable "pcf_networks" {
  type = "map"

  default = {
    sandbox = {
      service_networks    = "services,dynamic-services"
      subnet_config_order = "infrastructure,pas-1,services-1,dynamic-services-1,monitoring"
    }
  }
}

# The CIDRs of the PCF Networks subnets. The range 192.168.0.0/22 
# is reserved for bootstrap services and should not be used for PCF 
# environments.  Multiple subnets must post-fix the network name 
# with '-#' for each subnet. Subnets are additive once they have 
# been created.

#export TF_VAR_pcf_network_subnets='{
#  sandbox = {
#    infrastructure     = "192.168.101.0/26"
#    pas-1              = "192.168.4.0/22"
#    services-1         = "192.168.8.0/22"
#    dynamic-services-1 = "192.168.12.0/22"
#    monitoring         = "192.168.101.64/26"
#  }
#}
variable "pcf_network_subnets" {
  type = "map"

  default = {
    sandbox = {
      infrastructure     = "192.168.101.0/26"
      pas-1              = "192.168.4.0/22"
      services-1         = "192.168.8.0/22"
      dynamic-services-1 = "192.168.12.0/22"
      monitoring         = "192.168.101.64/26"
    }
  }
}

# Comma separated list of additional DNS hosts to use
# for instances deployed to the pcf networks.
variable "pcf_network_dns" {
  default = "169.254.169.254"
}

#
# PCF Install params
#

variable "pivnet_token" {
  type = "string"
}
