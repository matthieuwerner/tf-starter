
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "this" {
  name = "frontend_php"
  build {
    path = "${path.module}/image"
    build_arg = {
      PROJECT_NAME : var.name
      PHP_VERSION : var.php_version
    }
  }
}

resource "docker_container" "this" {
  name  = var.name
  image = docker_image.this.latest
  networks_advanced {
    name = var.network
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.name}-frontend.rule"
    value = "Host(`www.${var.domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.name}-frontend.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.name}-frontend-unsecure.rule"
    value = "Host(`www.${var.domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.name}-frontend-unsecure.middlewares"
    value = "redirect-to-https@file"
  }

  volumes {
    host_path      = "${path.cwd}/application"
    container_path = "/home/app/application"
  }
}
