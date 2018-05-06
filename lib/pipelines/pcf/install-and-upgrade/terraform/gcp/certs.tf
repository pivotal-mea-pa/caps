#
# Certificate for PCF ERT end-point
#

resource "tls_private_key" "pcf-san-cert" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "pcf-san-cert" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.pcf-san-cert.private_key_pem}"

  dns_names = [
    "*.${local.bootstrap_domain}",
    "*.${local.pas_domain}",
    "*.${local.apps_domain}",
    "*.${local.system_domain}",
    "*.uaa.${local.system_domain}",
    "*.login.${local.system_domain}",
  ]

  subject {
    common_name         = "${local.pas_domain}"
    organization        = "${data.terraform_remote_state.bootstrap.company_name}"
    organizational_unit = "${data.terraform_remote_state.bootstrap.organization_name}"
    locality            = "${data.terraform_remote_state.bootstrap.locality}"
    province            = "${data.terraform_remote_state.bootstrap.province}"
    country             = "${data.terraform_remote_state.bootstrap.country}"
  }
}

# Sign certificate with Root CA from bootstrap state.
resource "tls_locally_signed_cert" "pcf-san-cert" {
  cert_request_pem = "${tls_cert_request.pcf-san-cert.cert_request_pem}"

  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${data.terraform_remote_state.bootstrap.root_ca_key}"
  ca_cert_pem        = "${data.terraform_remote_state.bootstrap.root_ca_cert}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "data_encipherment",
    "server_auth",
  ]
}

# Save ERT SAN certificate as GCP cert
resource "google_compute_ssl_certificate" "ert-san-cert" {
  name        = "${var.prefix}-ert-san-cert"
  certificate = "${length(var.pcf_ert_ssl_cert) > 0 ? var.pcf_ert_ssl_cert : tls_locally_signed_cert.pcf-san-cert.cert_pem}"
  private_key = "${length(var.pcf_ert_ssl_key) > 0 ? var.pcf_ert_ssl_key : tls_private_key.pcf-san-cert.private_key_pem}"

  lifecycle {
    create_before_destroy = true
  }
}

# This needs to be removed as it creates 
# a race condition when renaming the resource
resource "google_compute_ssl_certificate" "lb-cert" {
  name        = "${var.prefix}-lb-cert"
  certificate = "${length(var.pcf_ert_ssl_cert) > 0 ? var.pcf_ert_ssl_cert : tls_locally_signed_cert.pcf-san-cert.cert_pem}"
  private_key = "${length(var.pcf_ert_ssl_key) > 0 ? var.pcf_ert_ssl_key : tls_private_key.pcf-san-cert.private_key_pem}"

  lifecycle {
    create_before_destroy = true
  }
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
    common_name         = "${local.pas_domain}"
    organization        = "${data.terraform_remote_state.bootstrap.company_name}"
    organizational_unit = "${data.terraform_remote_state.bootstrap.organization_name}"
    locality            = "${data.terraform_remote_state.bootstrap.locality}"
    province            = "${data.terraform_remote_state.bootstrap.province}"
    country             = "${data.terraform_remote_state.bootstrap.country}"
  }
}

# Sign certificate with Root CA from bootstrap state.
resource "tls_locally_signed_cert" "saml-san" {
  cert_request_pem = "${tls_cert_request.saml-san.cert_request_pem}"

  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${data.terraform_remote_state.bootstrap.root_ca_key}"
  ca_cert_pem        = "${data.terraform_remote_state.bootstrap.root_ca_cert}"

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "data_encipherment",
    "server_auth",
  ]
}
