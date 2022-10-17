
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "builder_php" {
  name = "builder_php"
  build {
    path = "${path.module}/image"
    build_arg = {
      COMPOSER_MEMORY_LIMIT : "-1"
      PHP_VERSION : var.php_version
    }
  }
}
