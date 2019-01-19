#
# Lookup VCenter resources
#

data "vsphere_datacenter" "dc" {
  name = "${local.vcenter_datacenter}"
}

data "vsphere_resource_pool" "rp" {
  name          = "${join("/", list(local.opsman_cluster_name, "Resources", local.opsman_cluster_resource_pool))}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "ds" {
  name          = "${local.opsman_vcenter_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "nw" {
  name          = "${local.opsman_vcenter_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "external" "pcf-availability-zones" {
  count = "${length(local.az_names)}"

  program = [
    "echo",
    <<RESULT
{
  "name": "${element(local.az_names, count.index)}",
  "cluster": "${lookup(local.availability_zones[element(local.az_names, count.index)], "cluster")}",
  "resource_pool": "${lookup(local.availability_zones[element(local.az_names, count.index)], "resource_pool", "")}"
}
RESULT
    ,
  ]
}

data "external" "pcf-networks" {
  count = "${length(local.subnet_names)}"

  program = [
    "echo",
    <<RESULT
{
  "network_name": "${replace(local.subnet_names[count.index], "/-[0-9]+$/", "")}",
  "is_service_network": "${contains(local.service_networks, replace(local.subnet_names[count.index], "/-[0-9]+$/", ""))}",
  "iaas_identifier": "${lookup(local.subnet_cidrs[local.subnet_names[count.index]], "vcenter_network_name")}",
  "cidr": "${lookup(local.subnet_cidrs[local.subnet_names[count.index]], "network_cidr")}",
  "gateway": "${lookup(local.subnet_cidrs[local.subnet_names[count.index]], "network_gateway")}",
  "reserved_ip_ranges": "${lookup(local.subnet_cidrs[local.subnet_names[count.index]], "reserved_ip_ranges")}",
  "availability_zone_names": "${join(",", local.az_names)}"
}
RESULT
    ,
  ]
}
