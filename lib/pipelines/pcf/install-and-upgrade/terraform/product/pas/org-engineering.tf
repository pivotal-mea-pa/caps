#
# Create Engineering Organization
#

resource "cloudfoundry_org" "engineering" {
  name = "engineering"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}
