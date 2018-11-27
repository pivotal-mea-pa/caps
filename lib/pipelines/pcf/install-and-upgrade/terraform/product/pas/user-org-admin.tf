#
# PCF org admin user
#

variable "org_admin" {
  type = "string"
}

resource "random_string" "pcf-org-admin-password" {
  length  = 10
  special = false
}

resource "cloudfoundry_user" "pcf-org-admin-user" {
  name        = "${var.org_admin}"
  password    = "${random_string.pcf-admin-password.result}"
  given_name  = "Org Administrator"
  family_name = "${data.terraform_remote_state.pcf.company_name}"
}

#
# Output PCF admin user credentials
#

output "pcf_org_admin_user" {
  value = "${cloudfoundry_user.pcf-org-admin-user.name}"
}

output "pcf_org_admin_password" {
  value = "${cloudfoundry_user.pcf-org-admin-user.password}"
}
