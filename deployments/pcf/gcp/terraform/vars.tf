#
# Externalized Variables
#

variable "trace" {
  default = "true"
}

variable "autostart_deployment_pipelines" {
  default = "true"
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

#
# Bastion inception instance variables
#
variable "bastion_instance_type" {
  default = "n1-standard-2"
}

variable "bastion_data_disk_size" {
  default = 250
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

# Email to forward notifications to
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

# Locale to use for time resources
variable "locale" {
  type = "string"
}

variable "automation_pipelines_repo" {
  default = "https://github.com/mevansam/caps.git"
}

variable "automation_pipelines_branch" {
  default = "master"
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

# PCF Ops Manager minor version to track
variable "opsman_major_minor_version" {
  type = "string"
}

# List of products to install. This should be a space 
# separated list of:
#
# product_name:product_slug/product_version_regex[:errands_to_disable[:errands_to_enable]]
#
# The 'errands_to_disable' and 'errands_to_enable' fields 
# should consist of comma separated errand names.
variable "products" {
  type = "string"
}

# Number of Diego Cells to deploy
variable "num_diego_cells" {
  default = "1"
}

#
# Backup / Restore pipeline params
#

variable "backup_interval" {
  default = "1h"
}

variable "backup_interval_start" {
  default = "02:00 AM"
}

variable "backup_interval_stop" {
  default = "02:30 AM"
}

variable "backup_age" {
  default = "2"
}

#
# Stop / Start event pipeline trigger time periods
#

# Time in 24h format (HH:MM) when deployments in the
# PCF environment should be stopped and VMs shutdown
variable "pcf_stop_at" {
  default = "0"
}

variable "pcf_stop_trigger_days" {
  default = "[Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]"
}

# Time in 24h format (HH:MM) when deployments
# in the PCF environment should be started
variable "pcf_start_at" {
  default = "0"
}

variable "pcf_start_trigger_days" {
  default = "[Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]"
}
