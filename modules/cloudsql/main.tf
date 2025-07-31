resource "google_sql_database_instance" "fittrack" {
  name = var.instance_name
  database_version = var.db_version
  region = var.region

  settings {
    tier=var.tier

    ip_configuration {
      ipv4_enabled = true
    
    dynamic "authorized_networks" {
    for_each = var.authorized_networks
    content {
      name  = authorized_networks.value.name
      value = authorized_networks.value.value
        }
       }
    }
    backup_configuration {
      enabled = true
      start_time = "3:00"
    }
    maintenance_window {
      day = 1
      hour = 23
    }
  }
  deletion_protection = false
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.fittrack.name
  charset  = var.db_charset
  collation = var.db_collation
}

resource "google_sql_user" "default" {
  name     = var.user_name
  instance = google_sql_database_instance.fittrack.name
  password = var.db_password
}