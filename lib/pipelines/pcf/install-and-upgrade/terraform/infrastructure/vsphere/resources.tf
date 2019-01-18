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
