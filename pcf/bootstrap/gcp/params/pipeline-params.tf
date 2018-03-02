#
# Parameters to be passed along when setting up the PCF pipelines
#

data "template_file" "pcf-pipeline-parameters" {
  template = "${file(var.params_template_file)}"

  vars {
    gcp_project     = "${data.terraform_remote_state.bootstrap.gcp_project}"
    gcp_credentials = "${indent(2, data.terraform_remote_state.bootstrap.gcp_credentials)}"
    gcp_region      = "${data.terraform_remote_state.bootstrap.gcp_region}"
    gcp_zone_1      = "${data.google_compute_zones.zones.names[0]}"
    gcp_zone_2      = "${data.google_compute_zones.zones.names[1]}"
    gcp_zone_3      = "${data.google_compute_zones.zones.names[2]}"

    gcp_storage_access_key = "${data.terraform_remote_state.bootstrap.gcp_storage_access_key}"
    gcp_storage_secret_key = "${data.terraform_remote_state.bootstrap.gcp_storage_secret_key}"

    vpc_name = "${data.terraform_remote_state.bootstrap.vpc_name}"

    pas_terraform_state_bucket = "${data.terraform_remote_state.bootstrap.pas_terraform_state_bucket}"

    pivnet_token           = "${data.terraform_remote_state.bootstrap.pivnet_token}"
    opsman_admin_password  = "${data.terraform_remote_state.bootstrap.opsman_admin_password}"
    vpc_dns_zone           = "${data.terraform_remote_state.bootstrap.vpc_dns_zone}"
    credhub_encryption_key = "${data.terraform_remote_state.bootstrap.credhub_encryption_key}"
    pas_system_dbpassword  = "${data.terraform_remote_state.bootstrap.pas_system_dbpassword}"

    mysql_monitor_recipient_email = "${data.terraform_remote_state.bootstrap.mysql_monitor_recipient_email}"
  }
}

resource "local_file" "params-yml" {
  content  = "${data.template_file.pcf-pipeline-parameters.rendered}"
  filename = "${var.params_file}"
}
