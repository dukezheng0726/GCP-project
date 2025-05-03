
resource "google_compute_health_check" "external_hc" {
  name                = "${var.name_prefix}-external-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "external_backend" {
  name                  = "${var.name_prefix}-external-backend"
  health_checks         = [google_compute_health_check.external_hc.self_link]
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = var.instance_group_app
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "external_urlmap" {
  name            = "${var.name_prefix}-external-urlmap"
  default_service = google_compute_backend_service.external_backend.self_link
}

resource "google_compute_target_http_proxy" "external_http_proxy" {
  name    = "${var.name_prefix}-external-http-proxy"
  url_map = google_compute_url_map.external_urlmap.self_link
}

resource "google_compute_global_forwarding_rule" "external_forwarding_rule" {
  name                  = "${var.name_prefix}-external-fwd-rule"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.external_http_proxy.self_link
  //depends_on            = [google_compute_subnetwork.lb_proxy]
}

