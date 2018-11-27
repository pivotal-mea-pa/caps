#
# Retrieve credentials from opsman
#

variable "opsman_target" {
  type = "string"
}

variable "opsman_client_id" {
  default = ""
}

variable "opsman_client_secret" {
  default = ""
}

variable "opsman_username" {
  default = "admin"
}

variable "opsman_password" {
  default = ""
}

data "external" "pks-uaa-creds" {
  program = ["om",
    "--skip-ssl-validation",
    "--target=https://${var.opsman_target}",
    "--client-id=${var.opsman_client_id}",
    "--client-secret=${var.opsman_client_secret}",
    "--username=${var.opsman_username}",
    "--password=${var.opsman_password}",
    "credentials",
    "--product-name=pivotal-container-service",
    "--format=json",
    "--credential-reference=.properties.pks_uaa_management_admin_client",
  ]
}

data "external" "bosh-creds" {
  program = ["${path.module}/bosh_credential.sh",
    "--skip-ssl-validation",
    "--target=https://${var.opsman_target}",
    "--client-id=${var.opsman_client_id}",
    "--client-secret=${var.opsman_client_secret}",
    "--username=${var.opsman_username}",
    "--password=${var.opsman_password}",
  ]
}
