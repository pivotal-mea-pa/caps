#
# PCF system admin user
#

resource "random_string" "pcf-admin-password" {
  length  = 10
  special = false
}

resource "cloudfoundry_user" "pcf-admin-user" {
  name        = "pcf-admin"
  password    = "${random_string.pcf-admin-password.result}"
  given_name  = "Administrator"
  family_name = "${data.terraform_remote_state.pcf.company_name}"
  groups      = ["cloud_controller.admin", "scim.read", "scim.write"]
}

#
# Output PCF admin user credentials
#

output "pcf_admin_user" {
  value = "${cloudfoundry_user.pcf-admin-user.name}"
}

output "pcf_admin_password" {
  value = "${cloudfoundry_user.pcf-admin-user.password}"
}
