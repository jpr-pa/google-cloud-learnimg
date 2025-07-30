provider "google" {
  project = "data-hangout-464703-u3"  # 🔁 Replace with your actual project ID
  region  = "asia-south1"
  zone    = "asia-south1-a"
}

data "google_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_address" "build_static" {
  name = "kayotsaha-static-ip"
  region = "asia-south-1"
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
  target_tags = ["kayotsaha-build-tag"]
}

resource "google_compute_instance" "kayotsaha-terra" {
  name         = "kayotsaha-terra"
  machine_type = "e2-standard-2"
  zone         = "asia-south1-a"
  tags         = ["kayotsaha-build-tag"]  

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
      nat_ip = "google_compute_address.build_static.address"
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("gcp-key.pub")}"
  }

  metadata_startup_script = <<-EOT
  #!/bin/bash
  apt update
  apt install -y python3 python3-pip docker.io docker-compose nginx git
  curl -O https://raw.githubusercontent.com/jpl-ry/to_run_and-_install_tools/master/install_jenkins.sh
  chmod +x *.sh
  ./install_jenkins.sh
EOT
}




