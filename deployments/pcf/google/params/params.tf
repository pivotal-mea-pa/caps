#
# Parameters to be passed along when setting up the PCF pipelines
#

data "template_file" "params" {
  template = "${file(var.params_template_file)}"

  vars = {
    gcp_project     = "${data.terraform_remote_state.bootstrap.outputs.gcp_project}"
    gcp_credentials = "${indent(2, data.terraform_remote_state.bootstrap.outputs.gcp_credentials)}"
    gcp_region      = "${data.terraform_remote_state.bootstrap.outputs.gcp_region}"

    gcp_storage_access_key = "${data.terraform_remote_state.bootstrap.outputs.gcp_storage_access_key}"
    gcp_storage_secret_key = "${data.terraform_remote_state.bootstrap.outputs.gcp_storage_secret_key}"

    terraform_state_bucket = "${data.terraform_remote_state.bootstrap.outputs.terraform_state_bucket}"
    bootstrap_state_prefix = "${data.terraform_remote_state.bootstrap.outputs.bootstrap_state_prefix}"

    vpc_name = "${data.terraform_remote_state.bootstrap.outputs.vpc_name}"

    environment = "${length(var.environment) > 0 
      ? var.environment 
      : data.terraform_remote_state.bootstrap.outputs.pcf_sandbox_environment}"

    automation_pipelines_repo   = "${data.terraform_remote_state.bootstrap.outputs.automation_pipelines_repo}"
    automation_pipelines_branch = "${data.terraform_remote_state.bootstrap.outputs.automation_pipelines_branch}"

    inceptor_pipelines_repo   = "${data.terraform_remote_state.bootstrap.outputs.inceptor_pipelines_repo}"
    inceptor_pipelines_branch = "${data.terraform_remote_state.bootstrap.outputs.inceptor_pipelines_branch}"

    automation_extensions_repo   = "${data.terraform_remote_state.bootstrap.outputs.automation_extensions_repo}"
    automation_extensions_branch = "${data.terraform_remote_state.bootstrap.outputs.automation_extensions_branch}"

    pcf_terraform_templates_path = "${data.terraform_remote_state.bootstrap.outputs.pcf_terraform_templates_path}"
    pcf_tile_templates_path      = "${data.terraform_remote_state.bootstrap.outputs.pcf_tile_templates_path}"

    vpc_dns_zone = "${data.terraform_remote_state.bootstrap.outputs.vpc_dns_zone}"

    pivnet_token           = "${data.terraform_remote_state.bootstrap.outputs.pivnet_token}"
    opsman_admin_password  = "${data.terraform_remote_state.bootstrap.outputs.opsman_admin_password}"
    common_admin_password  = "${data.terraform_remote_state.bootstrap.outputs.common_admin_password}"
    pas_system_dbpassword  = "${data.terraform_remote_state.bootstrap.outputs.pas_system_dbpassword}"
    credhub_encryption_key = "${data.terraform_remote_state.bootstrap.outputs.credhub_encryption_key}"

    backups_bucket = "${data.terraform_remote_state.bootstrap.outputs.backups_bucket}"
  }
}

resource "local_file" "params" {
  content  = "${data.template_file.params.rendered}"
  filename = "${var.params_file}"
}
