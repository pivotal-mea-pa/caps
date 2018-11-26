#
# Creare PKS admin user
#

variable "pks_admin_username" {
  type = "string"
}

variable "pks_admin_password" {
  type = "string"
}

variable "pks_admin_email" {
  type = "string"
}

resource "uaa_user" "pks-admin-user" {
  name        = "${var.pks_admin_username}"
  password    = "${var.pks_admin_password}"
  given_name  = "PKS Administrator"
  family_name = "${data.terraform_remote_state.pcf.company_name}"
  groups      = ["pks.clusters.admin"]
}
