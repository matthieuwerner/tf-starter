
locals {
  prefix = "${var.prefix}${var.name}_"
  domain = "${var.prefix}${var.name}.test"
}

# --------------------------------------
# Network
# --------------------------------------
# Define a Docker network for the stack
module "docker_network" {
  source = "network"

  name = "${local.prefix}network"
}

# --------------------------------------
# Router
# --------------------------------------
# Use a Traefik as a local router module.
module "docker_router" {
  source = "traefik"

  name    = "${local.prefix}router"
  network = module.docker_network.name
}

# --------------------------------------
# Builder
# --------------------------------------
# This image is used to build stuff and
# run commands.
module "docker_builder" {
  source = "builder-php"
}

# --------------------------------------
# Nginx
# --------------------------------------
# Boot a frontend web server based on
# nginx and php-fpm.
#module "docker_front_php" {
#  source = "./front-php"
#  name = "${local.prefix}front-php"
#  domain = "${local.domain}front-php"
#  network = module.docker_network.name
#}

# --------------------------------------
# Bref-sh
# --------------------------------------
# Boot a frontend web server based on
# nginx and php-fpm with a configuration
# very close to a lambda environment.
module "docker_bref_sh" {
  source  = "bref-sh"
  name    = "${local.prefix}lambda-php"
  domain  = local.domain
  network = module.docker_network.name
}

output "human_readable" {
  //value = fileset(path.root, "config/**.yaml")
  //value = [for filePath in local.file_set : yamldecode(file(filePath))[0]]
  #  flatten(formatlist(
  #"Module '%s' installed",
  #[for o in module.local[0] : o]
  #))
  value = "test"
}

output "path" {
  value = module.docker_bref_sh.id
}

# --------------------------------------
# PostgreSQL
# --------------------------------------
# Database engine with PostgreSQL and
# pgadmin.
module "docker_postgresql" {
  source  = "postgresql"
  name    = "${local.prefix}postgresql"
  network = module.docker_network.name
}

# --------------------------------------
# MariaDB
# --------------------------------------

# --------------------------------------
# Dynamo local ?
# --------------------------------------

# --------------------------------------
# Elasticsearch
# --------------------------------------

# --------------------------------------
# Redis
# --------------------------------------

# --------------------------------------
# RabbitMQ
# --------------------------------------

# --------------------------------------
# SQS local ?
# --------------------------------------


