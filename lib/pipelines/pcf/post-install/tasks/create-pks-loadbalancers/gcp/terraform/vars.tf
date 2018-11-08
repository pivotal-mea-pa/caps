#
# External variables for setting up 
# loadbalancers for K8S launched by PKS
#

variable "clusters" {
  type = "list"
}

variable "cluster_ids" {
  type = "map"
}

variable "cluster_instances" {
  type = "map"
}
