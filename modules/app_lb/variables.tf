variable "region" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_group_app" {
  type = string
}
