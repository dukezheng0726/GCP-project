data "google_compute_image" "centos" {
  family  = "rocky-linux-8"
  project = "rocky-linux-cloud"
}

resource "google_compute_firewall" "fw_http" {
  name        = "${var.name_prefix}-allow-http"
  network     = var.network
  priority    = 1
  direction   = "INGRESS"
  target_tags = ["${var.name_prefix}-server"] # 只有带有 "http-server" 标签的实例会应用这个规则

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"] # 允许所有 IP 访问
}

resource "google_compute_instance_template" "this" {
  name         = "${var.name_prefix}-template"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = data.google_compute_image.centos.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = var.network

    dynamic "access_config" {
      //for_each = var.name_prefix == "web" ? [0] : [0]
      //content {}
          
      for_each = []
      content {}

    }
  }

  metadata_startup_script = var.startup_script
  tags                    = ["${var.name_prefix}-server"]
}


