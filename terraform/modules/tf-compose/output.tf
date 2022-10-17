
// Current workspace.
output "workspace" {
  value = terraform.workspace
}

# Modules list for the current environment.
output "modules_list" {
  value = local.configuration.modules
}

# Modules output
output "function-php" {
  value = module.function-php
}
