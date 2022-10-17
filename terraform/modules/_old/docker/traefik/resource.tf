
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "router" {
  name = "router"
  build {
    path = "${path.module}/image"
  }
}

resource "docker_container" "this" {
  name         = var.name
  image        = docker_image.router.latest
  network_mode = "host"
  mounts {
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
    type   = "bind"
  }
}
