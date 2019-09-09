#
# Certificate for PCF ERT end-point
#

locals {
  ert_ssl_cert = "${length(var.pcf_ert_ssl_cert) > 0 ? var.pcf_ert_ssl_cert : tls_locally_signed_cert.pcf-san-cert.cert_pem}"
  ert_ssl_key  = "${length(var.pcf_ert_ssl_key) > 0 ? var.pcf_ert_ssl_key : tls_private_key.pcf-san-cert.private_key_pem}"
}

resource "tls_private_key" "pcf-san-cert" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "pcf-san-cert" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.pcf-san-cert.private_key_pem}"

  dns_names = [
    "*.${local.bootstrap_domain}",
    "*.${local.env_domain}",
    "*.${local.apps_domain}",
    "*.${local.system_domain}",
    "*.uaa.${local.system_domain}",
    "*.login.${local.system_domain}",
  ]

  subject {
    common_name         = "${local.env_domain}"
    organization        = "${data.terraform_remote_state.bootstrap.outputs.company_name}"
    organizational_unit = "${data.terraform_remote_state.bootstrap.outputs.organization_name}"
    locality            = "${data.terraform_remote_state.bootstrap.outputs.locality}"
    province            = "${data.terraform_remote_state.bootstrap.outputs.province}"
    country             = "${data.terraform_remote_state.bootstrap.outputs.country}"
  }
}

# Sign certificate with Root CA from bootstrap state.
resource "tls_locally_signed_cert" "pcf-san-cert" {
  cert_request_pem = "${tls_cert_request.pcf-san-cert.cert_request_pem}"

  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${data.terraform_remote_state.bootstrap.outputs.root_ca_key}"
  ca_cert_pem        = "${data.terraform_remote_state.bootstrap.outputs.root_ca_cert}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "data_encipherment",
    "server_auth",
  ]
}

#
# Certificate for PCF SAML end-point
#

resource "tls_private_key" "saml-san" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "saml-san" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.saml-san.private_key_pem}"

  dns_names = [
    "*.${local.apps_domain}",
    "*.${local.system_domain}",
    "*.uaa.${local.system_domain}",
    "*.login.${local.system_domain}",
  ]

  subject {
    common_name         = "${local.env_domain}"
    organization        = "${data.terraform_remote_state.bootstrap.outputs.company_name}"
    organizational_unit = "${data.terraform_remote_state.bootstrap.outputs.organization_name}"
    locality            = "${data.terraform_remote_state.bootstrap.outputs.locality}"
    province            = "${data.terraform_remote_state.bootstrap.outputs.province}"
    country             = "${data.terraform_remote_state.bootstrap.outputs.country}"
  }
}

# Sign certificate with Root CA from bootstrap state.
resource "tls_locally_signed_cert" "saml-san" {
  cert_request_pem = "${tls_cert_request.saml-san.cert_request_pem}"

  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${data.terraform_remote_state.bootstrap.outputs.root_ca_key}"
  ca_cert_pem        = "${data.terraform_remote_state.bootstrap.outputs.root_ca_cert}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "data_encipherment",
    "server_auth",
  ]
}
