output "db_host" {
  value = [
    for address in google_sql_database_instance.db_instance.ip_address :
    address.ip_address if address.type == "PRIMARY"
  ][0]
}

output "db_user" {
  value = var.db_user
}

output "db_password" {
  value = var.db_password
}

output "db_name" {
  value = var.db_name
}
