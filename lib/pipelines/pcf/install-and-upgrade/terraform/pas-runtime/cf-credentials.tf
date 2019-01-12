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

data "external" "pas-cf-creds" {
  program = ["om",
    "--skip-ssl-validation",
    "--target=https://${var.opsman_target}",
    "--client-id=${var.opsman_client_id}",
    "--client-secret=${var.opsman_client_secret}",
    "--username=${var.opsman_username}",
    "--password=${var.opsman_password}",
    "credentials",
    "--product-name=cf",
    "--format=json",
    "--credential-reference=.uaa.admin_credentials",
  ]
}

data "external" "pas-uaa-creds" {
  program = ["om",
    "--skip-ssl-validation",
    "--target=https://${var.opsman_target}",
    "--client-id=${var.opsman_client_id}",
    "--client-secret=${var.opsman_client_secret}",
    "--username=${var.opsman_username}",
    "--password=${var.opsman_password}",
    "credentials",
    "--product-name=cf",
    "--format=json",
    "--credential-reference=.uaa.admin_client_credentials",
  ]
}
