variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_template_id" {
  description = "ID of the instance template"
  type        = string
}


variable "min_replicas" {
  type    = string
  default = "2"
}
 
variable "max_replicas" {
  type    = string
  default = "4"
}

variable "region" {
  type = string
}