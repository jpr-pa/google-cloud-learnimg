data "google_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_address" "build-static" {
  name = "build-static" 
  region = "asia-south1"
}

resource "google_compute_firewall" "build-body" {
  name =   "build-body"
  network = "default"

  allow {
    protocol = "tcp"
    ports = [
      "22",
      "3306",
      "5000",
      "3000",
      "443",
      "80",
      "8080",
      "27017",
      "8000",
    ]
  }
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = var.instance_tags
}

resource "google_compute_instance" "kayotsaha-terra" {
  name         = var.instance-name
  machine_type = var.working_type
  zone         = var.zone
  tags         = var.instance_tags 

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 35
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.build-static.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = var.startup_script
}





