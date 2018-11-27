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

#
# Spring Music Demo Spaces
#

resource "cloudfoundry_space" "demo-sm-dev" {
  name = "sm-dev"
  org  = "${cloudfoundry_org.demo.id}"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]

  developers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}

resource "cloudfoundry_space" "demo-sm-test" {
  name = "sm-test"
  org  = "${cloudfoundry_org.demo.id}"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]

  developers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}

resource "cloudfoundry_space" "demo-sm-prod" {
  name = "sm-prod"
  org  = "${cloudfoundry_org.demo.id}"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]

  developers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}

#
# Fortune Teller Demo Spaces
#

resource "cloudfoundry_space" "demo-ft-dev" {
  name = "ft-dev"
  org  = "${cloudfoundry_org.demo.id}"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]

  developers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}

resource "cloudfoundry_space" "demo-ft-test" {
  name = "ft-test"
  org  = "${cloudfoundry_org.demo.id}"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]

  developers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}

resource "cloudfoundry_space" "demo-ft-prod" {
  name = "ft-prod"
  org  = "${cloudfoundry_org.demo.id}"

  managers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]

  developers = [
    "${cloudfoundry_user.pcf-org-admin-user.id}",
  ]
}
