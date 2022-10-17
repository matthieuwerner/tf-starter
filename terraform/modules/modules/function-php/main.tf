
#terraform {
#  required_version = "> 1.0"
#
#  required_providers {
#    docker = {
#      source = "kreuzwerker/docker"
#    }
#  }
#}

# --------------------------------------
# Docker
# --------------------------------------

module "docker" {
  count = var.current_provider == "docker" ? 1 : 0

  source = "./docker"

  # Generic variables
  network          = var.network

  # Overridable variables
  name             = var.name
  application_path = var.application_path
  document_root    = var.document_root
  handler          = var.handler
  php_version      = var.php_version
  domain           = var.domain
}

output "function-php" {
  value = module.docker
}

# --------------------------------------
# AWS
# --------------------------------------

#module "aws" {
#  count = var.current_provider == "aws" ? 1 : 0
#
#  source = "./aws"
#}
