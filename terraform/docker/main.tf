
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }

  backend "local" {
    path = "local.tfstate"
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

