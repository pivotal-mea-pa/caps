#
# Create demo organization
#

resource "cloudfoundry_org" "demo" {
  name = "demo"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}

resource "cloudfoundry_space" "demo-sandbox" {
  name = "sandbox"
  org  = "${cloudfoundry_org.demo.id}"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]

  developers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}
