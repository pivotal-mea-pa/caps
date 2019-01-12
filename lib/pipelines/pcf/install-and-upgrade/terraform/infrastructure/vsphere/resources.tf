#
# Lookup VCenter resources
#

data "vsphere_datacenter" "dc" {
  name = "${local.vcenter_datacenter}"
}

data "vsphere_compute_cluster" "cl" {
  name          = "${local.opsman_vcenter_cluster}"
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
