#
# Initialize PKS UAA provider
# 

provider "uaa" {
  login_endpoint      = "https://${data.terraform_remote_state.pcf.pks_url}:8443"
  auth_endpoint       = "https://${data.terraform_remote_state.pcf.pks_url}:8443"
  client_id           = "admin"
  client_secret       = "${data.external.pks-uaa-creds.result.secret}"
  skip_ssl_validation = true
}
