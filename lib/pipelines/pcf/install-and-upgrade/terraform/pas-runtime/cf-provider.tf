#
# Initialize CF Provider. 
#

#
# Cloud Foundry provider configuration
#

provider "cloudfoundry" {
  api_url             = "https://api.${data.terraform_remote_state.pcf.system_domain}"
  user                = "${data.external.pas-cf-creds.result.identity}"
  password            = "${data.external.pas-cf-creds.result.password}"
  uaa_client_id       = "${data.external.pas-uaa-creds.result.identity}"
  uaa_client_secret   = "${data.external.pas-uaa-creds.result.password}"
  skip_ssl_validation = true
}

#
# Cloud Foundry environment common data resources
#

data "cloudfoundry_info" "info" {}
