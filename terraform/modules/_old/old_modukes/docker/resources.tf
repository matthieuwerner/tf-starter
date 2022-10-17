
resource "docker_network" "tf-starter_network" {
  name = "${var.project_name}_network"
}

// Router --------------------------------
resource "docker_image" "router" {
  name = "router"
  build {
    path = "images/router"
  }
}

resource "docker_container" "router" {
  name         = "${var.project_name}_router"
  image        = docker_image.router.latest
  network_mode = "host"
  mounts {
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
    type   = "bind"
  }
}


// PHP base --------------------------------
resource "docker_image" "php-base" {
  name = "php-base"
  build {
    path = "images/php-base"
    build_arg = {
      PHP_VERSION : var.php_version
    }
  }
}


// Builder --------------------------------
resource "docker_image" "builder" {
  name       = "builder"
  depends_on = [docker_image.php-base]
  build {
    path = "images/builder"
    build_arg = {
      COMPOSER_MEMORY_LIMIT : "-1"
    }
  }
}


// Frontend --------------------------------
resource "docker_image" "frontend" {
  name       = "frontend"
  depends_on = [docker_image.php-base]
  build {
    path = "images/frontend"
    build_arg = {
      PROJECT_NAME : var.project_name
      PHP_VERSION : var.php_version
    }
  }
}

resource "docker_container" "frontend" {
  name         = "${var.project_name}_frontend"
  image        = docker_image.frontend.latest
  network_mode = "${var.project_name}_network"
  depends_on   = [docker_container.postgres]
  env          = var.env
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-frontend.rule"
    value = "Host(`www.${var.project_domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-frontend.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-frontend-unsecure.rule"
    value = "Host(`www.${var.project_domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-frontend-unsecure.middlewares"
    value = "redirect-to-https@file"
  }

  volumes {
    host_path      = "${path.cwd}/application"
    container_path = "/home/app/application"
  }
}


// Postgres --------------------------------
resource "docker_image" "postgres" {
  name = "postgres"
  build {
    path = "images/postgres"
  }
}

resource "docker_container" "postgres" {
  name         = "${var.project_name}_postgres"
  image        = docker_image.postgres.latest
  network_mode = "${var.project_name}_network"
  env          = ["POSTGRES_USER=app", "POSTGRES_PASSWORD=app"]
  volumes {
    volume_name    = "${var.project_name}-postgres-data"
    container_path = "/var/lib/postgresql/data"
  }
}






