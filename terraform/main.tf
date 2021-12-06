terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1g8rpon0a070cte64jt"
  folder_id = "b1giq47cia0l9tim5cpl"
  zone="ru-central1-b"
}

data "yandex_compute_image" "coi" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "instance-coi" {
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.coi.id
    }
  }
  network_interface {
    subnet_id = "e2lep8quibfestinq1rk"
    nat = true
  }
  resources {
    cores = 2
    memory = 2
  }
  metadata = {
    docker-container-declaration = file("${path.module}/declaration.yaml")
    user-data = file("${path.module}/cloud_config.yaml")
  }
}