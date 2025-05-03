output "app_lb_ip" {
  value = google_compute_forwarding_rule.internal_forwarding_rule.ip_address
}
