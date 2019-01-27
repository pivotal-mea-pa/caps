#
# Create a release engineering cluster user
#

resource "random_string" "pks-releng-password" {
  length  = 10
  special = false
}

resource "uaa_user" "pks-releng-user" {
  name        = "pks-releng"
  password    = "${random_string.pks-releng-password.result}"
  given_name  = "Release Engineering"
  family_name = "${data.terraform_remote_state.pcf.company_name}"
  groups      = ["pks.clusters.manage"]
}

#
# Create releng cluster
#

data "template_file" "pks-create-releng-cluster" {
  template = "${file("${path.module}/pks_create_cluster.sh")}"

  vars {
    ca_cert            = "${data.external.bosh-creds.result.ca_cert}"
    bosh_host          = "${data.external.bosh-creds.result.host}"
    bosh_client_id     = "${data.external.bosh-creds.result.client_id}"
    bosh_client_secret = "${data.external.bosh-creds.result.client_secret}"
    pks_url            = "${data.terraform_remote_state.pcf.pks_url}"
    user               = "${uaa_user.pks-releng-user.name}"
    password           = "${uaa_user.pks-releng-user.password}"
    cluster_name       = "pks-releng"
    cluster_domain     = "${data.terraform_remote_state.pcf.env_domain}"
    plan               = "small"
  }
}

data "template_file" "pks-delete-releng-cluster" {
  template = "${file("${path.module}/pks_delete_cluster.sh")}"

  vars {
    ca_cert            = "${data.external.bosh-creds.result.ca_cert}"
    bosh_host          = "${data.external.bosh-creds.result.host}"
    bosh_client_id     = "${data.external.bosh-creds.result.client_id}"
    bosh_client_secret = "${data.external.bosh-creds.result.client_secret}"
    pks_url            = "${data.terraform_remote_state.pcf.pks_url}"
    user               = "${uaa_user.pks-releng-user.name}"
    password           = "${uaa_user.pks-releng-user.password}"
    cluster_name       = "pks-releng"
    cluster_domain     = "${data.terraform_remote_state.pcf.env_domain}"
    plan               = "small"
  }
}

resource "null_resource" "pks-releng-cluster" {
  provisioner "local-exec" {
    command = "/bin/bash -c '${data.template_file.pks-create-releng-cluster.rendered}'"
  }

  provisioner "local-exec" {
    command = "/bin/bash -c '${data.template_file.pks-delete-releng-cluster.rendered}'"
    when    = "destroy"
  }
}

#
# Output PKS releng user credentials
#

output "pks_releng_user" {
  value = "${uaa_user.pks-releng-user.name}"
}

output "pks_releng_password" {
  value = "${uaa_user.pks-releng-user.password}"
}
