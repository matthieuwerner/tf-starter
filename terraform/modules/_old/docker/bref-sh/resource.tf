
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "fpm-dev-gateway" {
  name = "bref/fpm-dev-gateway"
}

resource "docker_image" "php-81-fpm-dev" {
  name = "bref/php-81-fpm-dev"
}

resource "docker_container" "fpm-dev-gateway" {
  name       = var.name
  image      = docker_image.fpm-dev-gateway.latest
  depends_on = [docker_container.php-81-fpm-dev]
  env = [
    "HANDLER=public/index.php",
    "DOCUMENT_ROOT=public"
  ]
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
    label = "traefik.http.routers.${var.name}-frontend-unsecure.rule"
    value = "Host(`www.${var.domain}`)"
  }
  volumes {
    host_path      = abspath("${path.root}/../application")
    container_path = "/var/task"
  }
}

resource "docker_container" "php-81-fpm-dev" {
  name  = "php" # Have to be named php as in Bref Dockerfile
  image = docker_image.php-81-fpm-dev.latest
  networks_advanced {
    name = var.network
  }
  volumes {
    host_path      = abspath("${path.root}/../application")
    container_path = "/var/task"
    read_only      = true
  }
}
