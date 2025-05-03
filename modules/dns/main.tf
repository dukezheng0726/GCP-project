resource "google_dns_managed_zone" "zone" {
  name        = var.zone_name
  dns_name    = "${var.domain_name}."
}


resource "google_dns_record_set" "www_a_record" {
  name         = "${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas = [var.domain_ip]
}
