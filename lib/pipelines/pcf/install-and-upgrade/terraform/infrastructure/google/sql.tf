#
# External GCP SQL database instance for PCF services
#

resource "google_sql_database_instance" "master" {
  region           = "${data.terraform_remote_state.bootstrap.outputs.gcp_region}"
  database_version = "MYSQL_5_6"
  name             = "${local.prefix}-${lower(random_string.db_instance_name_postfix.result)}"

  timeouts {
    # GCP Takes a long time to create SQL instances.
    create = "30m"
    delete = "30m"
  }

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks = ["${data.null_data_source.authorized_networks.*.outputs}"]
    }
  }
}

resource "random_string" "db_instance_name_postfix" {
  length  = 16
  special = false
}

data "null_data_source" "authorized_networks" {
  count = "${local.num_azs}"

  inputs = {
    name  = "${element(google_compute_instance.nat-gateway.*.name, count.index)}"
    value = "${element(google_compute_instance.nat-gateway.*.network_interface.0.access_config.0.nat_ip, count.index)}"
  }
}

resource "google_sql_database" "uaa" {
  count    = "${var.pas_db_type == "internal" ? 0 : 1}"
  name     = "uaa"
  instance = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "ccdb" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "ccdb"
  depends_on = ["google_sql_database.uaa"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "notifications" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "notifications"
  depends_on = ["google_sql_database.ccdb"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "autoscale" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "autoscale"
  depends_on = ["google_sql_database.notifications"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "app_usage_service" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "app_usage_service"
  depends_on = ["google_sql_database.autoscale"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "console" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "console"
  depends_on = ["google_sql_database.app_usage_service"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "routing" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "routing"
  depends_on = ["google_sql_database.console"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "diego" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "diego"
  depends_on = ["google_sql_database.routing"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "account" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "account"
  depends_on = ["google_sql_database.diego"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "nfsvolume" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "nfsvolume"
  depends_on = ["google_sql_database.account"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "networkpolicyserver" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "networkpolicyserver"
  depends_on = ["google_sql_database.nfsvolume"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "locket" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "locket"
  depends_on = ["google_sql_database.networkpolicyserver"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "silk" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "silk"
  depends_on = ["google_sql_database.locket"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "credhub" {
  count      = "${var.pas_db_type == "internal" ? 0 : 1}"
  name       = "credhub"
  depends_on = ["google_sql_database.silk"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "eventalerts" {
  count      = "${var.event_alerts_db_type == "internal" ? 0 : 1}"
  name       = "eventalerts"
  depends_on = ["google_sql_database.credhub"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_user" "pas-db-user" {
  name     = "${var.db_username}"
  password = "${var.db_password}"
  instance = "${google_sql_database_instance.master.name}"
  host     = "%"
}
