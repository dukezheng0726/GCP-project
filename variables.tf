variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "gcp-project-458513"
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "network" {
  type    = string
  default = "default"
}

variable "subnetwork" {
  type    = string
  default = "default"
}

variable "instance_count" {
  description = "Number of instances in MIG"
  type        = number
  default     = 2
}


//sql
variable "db_user" {
  description = "Database user"
  type        = string
  default     = "dbuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "123456"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "metrocdb"
}
