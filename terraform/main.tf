
terraform {
  required_version = "> 1.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
  }

  backend "local" {}
}

# Docker provider
provider "docker" {
  alias = "local"
  host  = var.docker_sock_path
}

variable "docker_sock_path" {
  description = "Path to your local docker.sock."
  default     = "unix:///var/run/docker.sock"
}

# AWS provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

variable "aws_region" {
  description = "AWS region."
  default     = "eu-west-3"
}

variable "aws_profile" {
  description = "AWS profile."
  default     = "default"
}

# TF compose
module "tf-compose" {
  source = "./modules/tf-compose"

  # If hosted on github
  # source = "github.com/matthieuwerner/tf-compose"

  # If hosted on TF registry
  # source = "tf-compose/tf-compose"
  # version = "1.0.0"

  # Available options: (uncomment if needed)
  # modules_config_file = ""
  # name = ""
  # prefix = ""
  # default_module = ""
  # default_domain = ""
}

output "compose" {
  value = module.tf-compose
}