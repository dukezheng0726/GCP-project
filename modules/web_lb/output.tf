
output "web_lb_ip" {
  value = google_compute_global_forwarding_rule.external_forwarding_rule.ip_address
}