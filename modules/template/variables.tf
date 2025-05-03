variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "region" {
  type = string
}

variable "network" {
  type    = string
  default = "default"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "startup_script" {
  description = "The startup script content"
  type        = string
}