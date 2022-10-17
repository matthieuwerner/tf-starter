
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "postgres" {
  name = "postgres"
  build {
    path = "${path.module}/image"
  }
}

resource "docker_container" "this" {
  name  = var.name
  image = docker_image.postgres.latest
  env   = ["POSTGRES_USER=app", "POSTGRES_PASSWORD=app"]
  networks_advanced {
    name = var.network
  }
  volumes {
    volume_name    = "${var.name}-postgres-data"
    container_path = "/var/lib/postgresql/data"
  }
}
