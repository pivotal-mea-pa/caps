#
# External variables for setting up 
# loadbalancers for K8S launched by PKS
#

variable "vpc_name" {
  type = "string"
}

variable "pks_domain" {
  type = "string"
}

variable "pks_dns_zone_name" {
  type = "string"
}

variable "pks_network_name" {
  type = "string"
}

variable "clusters" {
  type = "list"
}

variable "cluster_ids" {
  type = "map"
}

variable "cluster_instances" {
  type = "map"
}
