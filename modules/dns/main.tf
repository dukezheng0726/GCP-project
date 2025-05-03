resource "google_dns_managed_zone" "this" {
  name        = var.zone_name
  dns_name    = "${var.zone_name}."
  description = "Managed zone for ${var.zone_name}"
}


resource "google_dns_record_set" "web_record" {
  name         = "web.${var.zone_name}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.this.name

  rrdatas = [var.web_ip]
}
