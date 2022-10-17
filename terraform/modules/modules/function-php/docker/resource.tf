
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

# PHP FPM container
locals {
  php_images = {
    "7.2" = "bref/php-72-fpm-dev"
    "7.3" = "bref/php-73-fpm-dev"
    "7.4" = "bref/php-74-fpm-dev"
    "8.0" = "bref/php-80-fpm-dev"
    "8.1" = "bref/php-81-fpm-dev"
  }
}

resource "docker_image" "php-fpm" {
  name = local.php_images[var.php_version]
}

resource "docker_container" "php-fpm" {
  name  = "php" # Have to be named php as in Bref Dockerfile
  image = docker_image.php-fpm.latest
  networks_advanced {
    name = var.network
  }
  volumes {
    host_path      = abspath("${path.root}/${var.application_path}")
    container_path = "/var/task"
    read_only      = true
  }
}

# Nginx container (with same restrictions as AWS Lambda)
resource "docker_image" "fpm-dev-gateway" {
  name = "bref/fpm-dev-gateway"
}

resource "docker_container" "fpm-dev-gateway" {
  name       = "${var.name}-gateway"
  image      = docker_image.fpm-dev-gateway.latest
  depends_on = [docker_container.php-fpm]
  env = [
    "HANDLER=${var.handler}",
    "DOCUMENT_ROOT=${var.document_root}"
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
    value = "Host(`${var.domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.name}-frontend-unsecure.rule"
    value = "Host(`${var.domain}`)"
  }
  volumes {
    host_path      = abspath("${path.root}/${var.application_path}")
    container_path = "/var/task"
  }
}

