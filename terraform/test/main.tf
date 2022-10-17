
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

module "this" {
  for_each = {
    source = "attr0"
    attr1 = "attr1"
    attr2 = "attr2"
  }
  source = each.source
}
