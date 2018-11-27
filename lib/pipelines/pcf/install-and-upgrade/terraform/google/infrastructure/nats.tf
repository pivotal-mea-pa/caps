#
# NAT instances and routing for resources 
# within the pcf network. Resources
# that require NATing should be tagged with
# the label '${local.prefix}'.
#

resource "google_compute_instance" "nat-gateway" {
  count = "${local.num_azs}"

  name         = "${local.prefix}-nat-gateway-${count.index}"
  machine_type = "g1-small"
  zone         = "${data.google_compute_zones.available.names[count.index]}"

  allow_stopping_for_update = true

  can_ip_forward = true

  tags = [
    "${local.prefix}-nat-instance",
    "nat-traverse",
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${local.infrastructure_subnetwork}"

    access_config {
      // Ephemeral
    }
  }

  metadata_startup_script = <<EOF
#!/bin/bash -xe

sysctl -w net.ipv4.ip_forward=1
sed -i= 's/^[# ]*net.ipv4.ip_forward=[[:digit:]]/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

itf=$(ip a | awk '/^[0-9]+: (eth|ens?)[0-9]+:/{ print substr($2,1,length($2)-1) }')
iptables -t nat -A POSTROUTING -o $itf -j MASQUERADE

apt-get update
apt-get upgrade
EOF

  depends_on = [
    "google_compute_subnetwork.pcf",
  ]
}

resource "google_compute_route" "nat-route" {
  count = "${local.num_azs}"

  name                   = "${local.prefix}-nat-route-${count.index}"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.pcf.name}"
  next_hop_instance      = "${element(google_compute_instance.nat-gateway.*.name, count.index)}"
  next_hop_instance_zone = "${data.google_compute_zones.available.names[count.index]}"
  priority               = 800

  tags = ["${local.prefix}"]
}
