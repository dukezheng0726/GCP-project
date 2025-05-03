variable "db_instance" {
  type    = string
  default = "db-instance"
}


variable "db_version" {
  type    = string
  default = "MYSQL_8_0"
}

variable "db_tier" {
  type    = string
  default = "db-custom-2-4096"
}

variable "db_name" {
  type    = string
  default = "coursedb"
}

variable "db_user" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type    = string
  default = "Db123456"
}

variable "db_region" {
  type    = string
  default = "us-east1"
}
