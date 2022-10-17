
# TF Compose project configuration

# Name of the project. This name can be override in your configuration file
# in the "name" attribute of {workspace}. It can also being changed with the
# classic Terraform variable assignment, but we consider using the YAML as
# a best practice.
variable "name" {
  description = "Name of the project. This name will be added as a resource prefix."
  default     = "tf-starter"
}

# Domain of the project. This name can be override in your configuration file
# in the "domain" attribute of {workspace}. It can also being changed with the
# classic Terraform variable assignment, but we consider using the YAML as
# a best practice.
variable "domain" {
  description = "Default domain."
  default     = "tf-starter.local"
}

# Extra prefix. This prefix is used only if defined here and used as is as a resource
# prefix.
variable "prefix" {
  description = "Extra prefix. (optional)"
  default     = ""
}

# Modules config file. The module config file is a YAML who describe the entire stack. The
# file has to be structured as the following example:
# default:
#   provider: docker
#   domain: tf-starter.local
#   modules:
#     example-module:
#        example-attribute: "Hey!"
#     ...
# another-workspace:
#   provider: aws
#   modules:
#     example-module:
#        example-attribute: "Ho!"
#
# A full example of configuration is available here: [link to documentation]
variable "modules_config_file" {
  description = "YAML file who describes your module configuration."
  default     = "config/architecture.yaml"
}

# YAML variables. Variables passed to this list are replaced in they placeholder in the
# YAML configuration. You can provide dynamic values from external datasource.
# All the Terraform template syntax is available in this area: https://www.terraform.io/language/functions/templatefile
# For informations about variables injection, see Terraform input variables section:
# https://www.terraform.io/language/values/variables
variable "variables" {
  description = "YAML variables."
  type = map(string)
  default     = {}
}

# Providers configuration

# Docker sock path. This path can be override in your configuration file
# in the "configuration/sock" attribute of {provider}. It can also being changed with the
# classic Terraform variable assignment, but we consider using the YAML as
# a best practice.
variable "docker_sock_path" {
  description = "Path to the docker.sock."
  default     = "unix:///var/run/docker.sock"
}

# AWS region. This default region can be override in your configuration file
# in the "configuration/region" attribute of {provider}. It can also being changed with the
# classic Terraform variable assignment, but we consider using the YAML as
# a best practice.
variable "aws_region" {
  description = "AWS region."
  default     = "eu-west-3"
}

# AWS profile. This default profile can be override in your configuration file
# in the "configuration/profile" attribute of {provider}. It can also being changed with the
# classic Terraform variable assignment, but we consider using the YAML as
# a best practice.
variable "aws_profile" {
  description = "AWS profile."
  default     = "default"
}



# Default provider. The default provider is
#variable "default_provider" {
#  description = "Default provider."
#  default     = "docker"
#}