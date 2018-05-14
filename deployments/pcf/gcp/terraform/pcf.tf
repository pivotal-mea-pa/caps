#
# PCF Deployment Environments and Networks CIDRs. These 
# variables are not extracted into the environment control 
# file but can be overridden if required.
#

variable "pcf_environments" {
  type    = "list"
  default = ["pcf"]
}

variable "pcf_networks" {
  type = "map"

  default = {
    pcf = {
      service_networks = "services,dynamic-services"

      # The order in which subnets should be configured
      # in the Ops Manager director tile.
      subnet_config_order = "infrastructure,runtime-1,services-1,dynamic-services-1,monitoring"
    }
  }
}

variable "pcf_network_subnets" {
  type = "map"

  # The range 192.168.0.0/22 is reserved for bootstrap 
  # services and should not be used for PCF environments.
  # Multiple subnets must post-fix the network name with 
  # '-#' for each subnet. Subnets are additive once they
  # have been created.

  default = {
    pcf = {
      infrastructure     = "192.168.101.0/26"
      runtime-1          = "192.168.4.0/22"
      services-1         = "192.168.8.0/22"
      dynamic-services-1 = "192.168.12.0/22"
      monitoring         = "192.168.101.64/26"
    }
  }
}

variable "pcf_network_dns" {
  default = "8.8.8.8"
}
