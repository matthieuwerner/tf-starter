variable "project_name" {
  description = "Project name."
  type        = string
  default     = "tf-starter"
}

variable "project_domain" {
  description = "Project domain."
  type        = string
  default     = "tf-starter.test"
}

variable "php_version" {
  description = "PHP version."
  type        = string
  default     = "8.1"
}

variable "env" {
  description = "Environnement variables."
  type        = list(string)
  default = [
    "APP_NAME=tf-starter",
    "APP_DEBUG=true",
    "APP_ENV=dev"
  ]
}

