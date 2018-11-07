resource "random_pet" "sql_db" {
  length = 1
}

resource "google_sql_database_instance" "master" {
  region           = "${var.gcp_region}"
  database_version = "MYSQL_5_6"
  name             = "${var.prefix}-${random_pet.sql_db.id}"

  timeouts {
    # GCP Takes a long time to create SQL instances.
    create = "30m"
    delete = "30m"
  }

  settings {
    tier = "db-f1-micro"

    ip_configuration = {
      ipv4_enabled = true

      authorized_networks = [
        {
          name  = "nat-1"
          value = "${google_compute_address.nat-primary.address}"
        },
        {
          name  = "nat-2"
          value = "${google_compute_address.nat-secondary.address}"
        },
        {
          name  = "nat-3"
          value = "${google_compute_address.nat-tertiary.address}"
        },
        {
          name  = "all"
          value = "0.0.0.0/0"
        },
      ]
    }
  }
}

resource "google_sql_database" "uaa" {
  name     = "uaa"
  instance = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "ccdb" {
  name       = "ccdb"
  depends_on = ["google_sql_database.uaa"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "notifications" {
  name       = "notifications"
  depends_on = ["google_sql_database.ccdb"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "autoscale" {
  name       = "autoscale"
  depends_on = ["google_sql_database.notifications"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "app_usage_service" {
  name       = "app_usage_service"
  depends_on = ["google_sql_database.autoscale"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "console" {
  name       = "console"
  depends_on = ["google_sql_database.app_usage_service"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "routing" {
  name       = "routing"
  depends_on = ["google_sql_database.console"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "diego" {
  name       = "diego"
  depends_on = ["google_sql_database.routing"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "account" {
  name       = "account"
  depends_on = ["google_sql_database.diego"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "nfsvolume" {
  name       = "nfsvolume"
  depends_on = ["google_sql_database.account"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "networkpolicyserver" {
  name       = "networkpolicyserver"
  depends_on = ["google_sql_database.nfsvolume"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "locket" {
  name       = "locket"
  depends_on = ["google_sql_database.networkpolicyserver"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "silk" {
  name       = "silk"
  depends_on = ["google_sql_database.locket"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "credhub" {
  name       = "credhub"
  depends_on = ["google_sql_database.silk"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "eventalerts" {
  name       = "eventalerts"
  depends_on = ["google_sql_database.credhub"]
  instance   = "${google_sql_database_instance.master.name}"
}

resource "google_sql_user" "diego" {
  name     = "${var.db_username}"
  password = "${var.db_password}"
  instance = "${google_sql_database_instance.master.name}"
  host     = "%"
}
