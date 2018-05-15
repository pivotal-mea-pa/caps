// NAT Primary
resource "google_compute_instance" "nat-gateway-pri" {
  name           = "${var.prefix}-nat-gateway-pri"
  machine_type   = "n1-standard-1"
  zone           = "${var.gcp_zone_1}"
  can_ip_forward = true
  tags           = ["${var.prefix}-nat-instance", "nat-traverse"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20160610"
    }
  }

  network_interface {
    subnetwork = "${local.infrastructure_subnetwork}"

    # subnetwork = "${local.subnet_links["infrastructure"]}"

    access_config {
      nat_ip = "${google_compute_address.nat-primary.address}"
    }
  }

  metadata_startup_script = <<EOF
#! /bin/bash
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF
}

// NAT Secondary
resource "google_compute_instance" "nat-gateway-sec" {
  count = "${data.terraform_remote_state.bootstrap.max_azs >= 2 ? 1 : 0}"

  name           = "${var.prefix}-nat-gateway-sec"
  machine_type   = "n1-standard-1"
  zone           = "${var.gcp_zone_2}"
  can_ip_forward = true
  tags           = ["${var.prefix}-nat-instance", "nat-traverse"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20160610"
    }
  }

  network_interface {
    subnetwork = "${local.infrastructure_subnetwork}"

    # subnetwork = "${local.subnet_links["infrastructure"]}"

    access_config {
      nat_ip = "${google_compute_address.nat-secondary.address}"
    }
  }

  metadata_startup_script = <<EOF
  #! /bin/bash
  sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
  sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF
}

// NAT Tertiary
resource "google_compute_instance" "nat-gateway-ter" {
  count = "${data.terraform_remote_state.bootstrap.max_azs >= 3 ? 1 : 0}"

  name           = "${var.prefix}-nat-gateway-ter"
  machine_type   = "n1-standard-1"
  zone           = "${var.gcp_zone_3}"
  can_ip_forward = true
  tags           = ["${var.prefix}-nat-instance", "nat-traverse"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20160610"
    }
  }

  network_interface {
    subnetwork = "${local.infrastructure_subnetwork}"

    # subnetwork = "${local.subnet_links["infrastructure"]}"

    access_config {
      nat_ip = "${google_compute_address.nat-tertiary.address}"
    }
  }

  metadata_startup_script = <<EOF
  #! /bin/bash
  sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
  sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF
}

resource "google_compute_address" "nat-primary" {
  name = "${var.prefix}-nat-primary"
}

resource "google_compute_address" "nat-secondary" {
  name = "${var.prefix}-nat-secondary"
}

resource "google_compute_address" "nat-tertiary" {
  name = "${var.prefix}-nat-tertiary"
}

resource "google_compute_route" "nat-primary" {
  name                   = "${var.prefix}-nat-pri"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.pcf.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway-pri.name}"
  next_hop_instance_zone = "${var.gcp_zone_1}"
  priority               = 800
  tags                   = ["${var.prefix}"]
}

resource "google_compute_route" "nat-secondary" {
  count = "${data.terraform_remote_state.bootstrap.max_azs >= 2 ? 1 : 0}"

  name                   = "${var.prefix}-nat-sec"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.pcf.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway-sec.name}"
  next_hop_instance_zone = "${var.gcp_zone_2}"
  priority               = 800
  tags                   = ["${var.prefix}"]
}

resource "google_compute_route" "nat-tertiary" {
  count = "${data.terraform_remote_state.bootstrap.max_azs >= 3 ? 1 : 0}"

  name                   = "${var.prefix}-nat-ter"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.pcf.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway-ter.name}"
  next_hop_instance_zone = "${var.gcp_zone_3}"
  priority               = 800
  tags                   = ["${var.prefix}"]
}
