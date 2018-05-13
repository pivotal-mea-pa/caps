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

  # The range 192.168.0.0/22 is reserved for
  # Bootstrap services so should not be used
  # for PCF environments.

  default = {
    pcf = {
      # A network named infrastructure is mandatory,
      # as it will be where the NATs gateways and
      # Ops Manager instance will be launched.
      infrastructure = "192.168.101.0/26"

      monitoring         = "192.168.101.64/26"
      runtime-1          = "192.168.4.0/22"
      services-1         = "192.168.8.0/22"
      dynamic-services-1 = "192.168.12.0/22"
    }
  }
}

variable "pcf_network_dns" {
  default = "8.8.8.8"
}
