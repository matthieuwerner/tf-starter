
locals {
  # Parse configuration
  yaml_vars    = var.variables
  yaml_content = yamldecode(templatefile(var.modules_config_file, local.yaml_vars))

  # Configuration
  configuration = local.yaml_content[terraform.workspace]

  # Domain
  domain        = try(local.configuration.domain, var.domain)

  # Naming
  prefix = "${var.prefix}${var.name}_"
}
