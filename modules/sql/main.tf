data "google_compute_network" "default" {
  name = "default"
}

resource "google_sql_database_instance" "db_instance" {
  name             = var.db_instance
  database_version = var.db_version
  region           = var.db_region

  settings {
    tier              = var.db_tier
    availability_type = "REGIONAL" 
    disk_size         = 10        
    disk_type         = "PD_SSD"      


    backup_configuration {
      enabled                        = true
      binary_log_enabled             = true
      start_time                     = "00:00"
      transaction_log_retention_days = 7
    }

    database_flags {
      name  = "log_bin_trust_function_creators"
      value = "on"
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }

  }

  root_password       = var.db_password
  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.db_instance.name
  depends_on = [
    google_sql_database_instance.db_instance
  ]
}

resource "google_sql_user" "app_user" {
  name     = var.db_user
  password = var.db_password
  instance = google_sql_database_instance.db_instance.name
  host     = "%"
}

//INSERT INTO grade (course, grade) VALUES ('JavaScript and Web Programming', 91)
//INSERT INTO grade (course, grade) VALUES ('Professional Development', 100)
resource "local_file" "init_sql" {
  content  = "CREATE TABLE IF NOT EXISTS grade (course VARCHAR(255), grade INT);INSERT INTO grade (course, grade) VALUES ('DevOps', 84);INSERT INTO grade (course, grade) VALUES ('AWS Solutions Architecture', 90);INSERT INTO grade (course, grade) VALUES ('Linux Fundamentals', 95);"
  filename = "${path.module}/init_db.sql"
}

resource "null_resource" "init_db" {
  triggers = {
    file_hash = sha256(local_file.init_sql.content)
  }

  provisioner "local-exec" {
    command = "mysql --host=${google_sql_database_instance.db_instance.ip_address[0].ip_address} --user=${var.db_user} --password=${var.db_password} --database=${var.db_name} < ${local_file.init_sql.filename}"
  }


  depends_on = [
    local_file.init_sql,
    google_sql_database.database,
    google_sql_user.app_user
  ]
}
