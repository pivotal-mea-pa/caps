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
# vCenter IaaS Environment
#

variable "vsphere_server" {
  type = "string"
}

variable "vsphere_user" {
  type = "string"
}

variable "vsphere_password" {
  type = "string"
}

variable "vsphere_allow_unverified_ssl" {
  type = "string"
}

variable "vcenter_datacenter" {
  type = "string"
}

# Resource paths in VCenter. This paths will be 
# prefixed by the environment.

variable "vcenter_templates_path" {
  default = "pcf-templates"
}

variable "vcenter_vms_path" {
  default = "pcf-vms"
}

variable "vcenter_disks_path" {
  default = "pcf-disks"
}

# Comma separated list of availability zone clusters
variable "vcenter_clusters" {
  type = "string"
}

# Comma separated list of ephemeral data stores
variable "vcenter_ephemeral_datastores" {
  type = "string"
}

# Comma separated list of persistent data stores
variable "vcenter_persistant_datastores" {
  type = "string"
}

# VCenter Networks

variable "dmz_network" {
  default = ""
}

variable "dmz_network_cidr" {
  default = ""
}

variable "dmz_network_gateway" {
  default = ""
}

variable "admin_network" {
  type = "string"
}

variable "admin_network_cidr" {
  type = "string"
}

variable "admin_network_gateway" {
  type = "string"
}

#
# Terraform state attributes
#

variable "s3_access_key_id" {
  type = "string"
}

variable "s3_secret_access_key" {
  type = "string"
}

variable "s3_default_region" {
  default = ""
}

variable "terraform_state_s3_endpoint" {
  default = ""
}

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

variable "vpc_cidr" {
  type = "string"
}

#
# Bastion inception instance variables
#
variable "bastion_instance_memory" {
  default = "4096"
}

variable "bastion_instance_cpus" {
  default = "2"
}

variable "bastion_root_disk_size" {
  default = "50"
}

variable "bastion_data_disk_size" {
  default = "250"
}

# IP for Bastion NIC on DMZ network segment. 
# Defaults to 31st IP of DMZ network's CIDR
# if value is empty.
variable "bastion_dmz_ip" {
  default = ""
}

# IP for Bastion NIC on Admin network segment. 
# Defaults to 31st IP of DMZ network's CIDR
# if value is empty.
variable "bastion_admin_ip" {
  default = ""
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

# Network configuration for each Ops Manager instance within
# each environment. Each configuration should be a map of
#
#  - cluster
#  - datastore
#  - network
#  - network_cidr
#  - network_gateway
#  - ip
#

#export TF_VAR_pcf_opsman_vcenter_config='{
#}'
variable "pcf_opsman_vcenter_config" {
  type = "map"
}

# The PCF logical networks to create. The order in which subnets 
# should be configured are provided via the 'subnet_config_order'
# key. If you need to add subnets always add to the end of this 
# list. Otherwise any reordering will result in networks being 
# recreated and may have undesired outcomes.

#export TF_VAR_pcf_networks='{
#  sandbox = {
#    service_networks    = "services,dynamic-services"
#    subnet_config_order = "infrastructure,pas-1,services-1,dynamic-services-1"
#  }
#}'
variable "pcf_networks" {
  type = "map"

  default = {
    sandbox = {
      service_networks    = "services,dynamic-services"
      subnet_config_order = "infrastructure,pas-1,services-1,dynamic-services-1"
    }
  }
}

# The CIDRs of the PCF Networks subnets. The range 192.168.0.0/22 
# is reserved for bootstrap services and should not be used for PCF 
# environments.  Multiple subnets must post-fix the network name 
# with '-#' for each subnet. Subnets are additive once they have 
# been created. Each subnet configuration should be a map of
# "vcenter_network_name", "network_cidr", "network_gateway" and 
# "reserved_ip_ranges" used to declare the logical Bosh networks.
#
# For example:
#
# {
#   sandbox = {
#     infrastructure = {
#       vcenter_network_name = "VM Network"
#       network_cidr         = "10.193.237.0/24"
#       network_gateway      = "10.193.237.1"
#       reserved_ip_ranges   = "10.193.237.1-10.193.237.32,10.193.237.40-10.193.237.254"
#     }
#     pas-1 = {
#       vcenter_network_name = "VM Network"
#       network_cidr         = "10.193.237.0/24"
#       network_gateway      = "10.193.237.1"
#       reserved_ip_ranges   = "10.193.237.1-10.193.237.39,10.193.237.70-10.193.237.254"
#     }
#     services-1 = {
#       vcenter_network_name = "VM Network"
#       network_cidr         = "10.193.237.0/24"
#       network_gateway      = "10.193.237.1"
#       reserved_ip_ranges   = "10.193.237.1-10.193.237.69,10.193.237.100-10.193.237.254"
#     }
#     dynamic-services-1 = {
#       vcenter_network_name = "VM Network"
#       network_cidr         = "10.193.237.0/24"
#       network_gateway      = "10.193.237.1"
#       reserved_ip_ranges   = "10.193.237.1-10.193.237.99,10.193.237.150-10.193.237.254"
#     }
#   }
# }'

#export TF_VAR_pcf_network_subnets='{
#}'
variable "pcf_network_subnets" {
  type = "map"
}

#
# PCF Install params
#

variable "pivnet_token" {
  type = "string"
}
