resource "google_compute_region_instance_group_manager" "this" {
  name               = "${var.name_prefix}-mig"
  base_instance_name = "${var.name_prefix}-instance"
  region             = var.region

  version {
    instance_template = var.instance_template_id
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_autoscaler" "this" {
  name   = "${var.name_prefix}-autoscaler"
  target = google_compute_region_instance_group_manager.this.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.80
    }
  }
}