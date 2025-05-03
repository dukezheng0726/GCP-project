//  instance_template_id = module.app_template.instance_template_id
output "instance_template_id" {
  value = google_compute_instance_template.this.id
}

