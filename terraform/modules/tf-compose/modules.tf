
# -------------------------------
# Network
# --------------------------------------
# Define a Docker network for the stack
# VPC si aws ?
module "network" {
  source = "../modules/network"

  name = "${local.prefix}network"
}

# --------------------------------------
# Router
# --------------------------------------
# Use a Traefik as a local router module.
# route 53 si aws ?
module "router" {
  source = "../modules/traefik"

  name    = "${local.prefix}router"
  network = module.network.name
}

# ------------------------------------------------
# Function PHP
# ------------------------------------------------
# Serverless function with PHP runtime.

module "function-php" {
  # Load module only if "function-php" is present in yaml configuration
  count = can(local.configuration.modules["function-php"]) ? 1 : 0

  # Module source path
  source = "../modules/function-php"
  # source = "github.com/matthieuwerner/tf-web-modules/function-php"

  # Generic variables
  current_provider = local.configuration.provider
  network          = module.network.name

  # Overridable variables
  name             = try("${local.prefix}${local.configuration.modules.function-php.name}", null) #*
  application_path = try(local.configuration.modules.function-php.application-path, null)         #*
  document_root    = try(local.configuration.modules.function-php.document-root, null)
  handler          = try(local.configuration.modules.function-php.handler, null)
  php_version      = try(local.configuration.modules.function-php.php-version, null)
  domain           = "${try(local.configuration.modules.function-php.subdomain, "www")}.${local.domain}"
}

#module "prout" {
#  source = "./modules/prout"
#  count = contains(local.modules, "s3") ? 1 : 0
#}
#
#output "test" {
#  value = module.prout[*].prout == [] ? "No init" : "Init"
#}


// Utiliser un hash généré automagiquement poar defaut (désactivable)


// intéréssant pour créer des images aws : https://docs.aws.amazon.com/lambda/latest/dg/images-create.html

// hummm, ça peut etre chanmé en fait pour copier docker starter en aws lambvda : https://aws.amazon.com/fr/blogs/france/nouveaute-pour-aws-lambda-prise-en-charge-des-images-de-conteneur/

//https://hub.docker.com/u/bref
// yamldecode(templatefile("rules/http.yaml", local.template_vars))
// if env local, provider docker
// permettre le multi modules simplement et utiliser ça dans le builder
//

