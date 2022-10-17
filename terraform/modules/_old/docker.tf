
#################################
## DOCKER MODULES CONFIGURATION #
#################################
#
#provider "docker" {
#  alias = "local"
#  host = var.docker_sock_path
#}
#
## Local environment (Docker)
#module "docker" {
#  count = local.configuration.provider == "docker" ? 1 : 0
#  source = "./modules/docker"
#
#  name = var.name
#  // modules = local.modules
#}
#
## Outputs
#output "docker" {
#  // @todo là on liste les output pas les modules non ? Sinon lister à partir du yaml filé en param et comparer ligne par ligne avec ce quiest lancé genre nom d emodul dynamique et paf
#  //value = module.local[0]
#  //value = [for k, v in module.local : module.local.docker_module.value ] // module.local[*].value
#  value = flatten(formatlist(
#      "Module '%s' installed",
#      [for container in module.docker[0] : container if contains(local.configuration.modules, container)]
#    ))
#}
