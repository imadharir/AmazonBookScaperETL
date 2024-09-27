data "external" "public_ip" {
  program = ["powershell", "-File", "get_public_ip.ps1"]
}

locals {
  authorized_ip = data.external.public_ip.result.public_ip
}

resource "google_sql_user" "postgres_user" {
  name     = var.postgres_username     
  instance = google_sql_database_instance.postgres_pvp_instance_name.name
  password = var.postgres_username  
  project  = var.project_id
  depends_on = [google_sql_database_instance.postgres_pvp_instance_name]
  
}

resource "google_sql_database" "database" {
  name     = "amazon_books"
  instance = google_sql_database_instance.postgres_pvp_instance_name.name
  charset  = "UTF8"
  collation = "en_US.UTF8"
  depends_on = [google_sql_database_instance.postgres_pvp_instance_name]
}



resource "google_sql_database_instance" "postgres_pvp_instance_name" {
  name             = "postgres-instance"
  project          = var.project_id
  region           = var.region
  database_version = "POSTGRES_14"
  root_password    = var.postgres_root_password
  settings {
    tier = "db-custom-4-16384"
    password_validation_policy {
      min_length                  = 6
      reuse_interval              = 2
      complexity                  = "COMPLEXITY_DEFAULT"
      disallow_username_substring = true
      password_change_interval    = "30s"
      enable_password_policy      = true
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.composer_vpc.self_link
      #require_ssl     = true
      authorized_networks {
        name  = "local-machine"
        value = "${local.authorized_ip}/32"
      }
    }
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]
  deletion_protection = false
}


