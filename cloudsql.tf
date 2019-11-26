# Cloud SQL instances cannot reuse names within one week of each other, so this
# allows the name to have a randomized suffix.
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# A Cloud SQL instance to used for the metadata of pipelines.
resource "google_sql_database_instance" "metadata_db_instance" {
  project          = "${var.project}"
  name             = "${var.cluster_name}-${random_id.db_name_suffix.hex}"
  database_version = "MYSQL_5_7"
  region           = "${var.cluster_region}"

  settings {
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "08:00"
    }

    replication_type = "SYNCHRONOUS"

    user_labels = {
      "application"              = "kubeflow"
      "env"                      = "${var.env_label}"
      "cloudsql-instance-suffix" = "${random_id.db_name_suffix.hex}"
    }

    tier = "db-n1-standard-4"

    location_preference {
      zone = "${var.cluster_zone}"
    }
  }
}

# Terraform deletes the default root user with no password that Cloud SQL
# creates (as a best practice?), so recreate it here
resource "google_sql_user" "root_user" {
  name     = "root"
  instance = "${google_sql_database_instance.metadata_db_instance.name}"
  password = ""
  host     = "%"
}

resource "google_sql_user" "read_only_user" {
  name     = "read_only"
  instance = "${google_sql_database_instance.metadata_db_instance.name}"
  password = "${var.mysql_read_only_user_password}"
  host     = "%"
}

resource "google_sql_user" "developer" {
  name     = "developer"
  instance = "${google_sql_database_instance.metadata_db_instance.name}"
  password = "${var.mysql_developer_password}"
  host     = "%"
}
