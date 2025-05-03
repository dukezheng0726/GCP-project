resource "google_compute_health_check" "internal_hc" {
  name                = "${var.name_prefix}-internal-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
  }
}

resource "google_compute_region_backend_service" "internal_backend" {
  name                  = "${var.name_prefix}-internal-backend"
  health_checks         = [google_compute_health_check.internal_hc.self_link]
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  region                = var.region

  backend {
    group           = var.instance_group_app
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_region_url_map" "internal_urlmap" {
  name            = "${var.name_prefix}-internal-urlmap"
  default_service = google_compute_region_backend_service.internal_backend.self_link
  region          = var.region
}

resource "google_compute_region_target_http_proxy" "internal_http_proxy" {
  name    = "${var.name_prefix}-internal-http-proxy"
  url_map = google_compute_region_url_map.internal_urlmap.self_link
  region  = var.region
}

resource "google_compute_forwarding_rule" "internal_forwarding_rule" {
  name                  = "${var.name_prefix}-internal-fwd-rule"
  load_balancing_scheme = "INTERNAL_MANAGED"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.internal_http_proxy.self_link
  region                = var.region
  network               = var.network
  subnetwork            = var.subnetwork
  depends_on            = [google_compute_subnetwork.lb_proxy]
}

resource "google_compute_subnetwork" "lb_proxy" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "192.168.0.0/23" # 必须为 /23
  region        = var.region
  network       = var.network # 或您的自定义 VPC
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}
