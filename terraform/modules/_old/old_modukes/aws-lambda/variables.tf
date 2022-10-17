variable "project_name" {
  description = "Project name used as function name."
  type        = string
  default     = "tf-starter"
}

variable "php_layer" {
  description = "PHP layer for your version."
  type        = string
  default     = "arn:aws:lambda:eu-west-3:209497400698:layer:php-81-fpm:16"
}

variable "entrypoint" {
  description = "Bref.sh PHP handler."
  type        = string
  default     = "public/index.php"
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-west-3"
}

variable "aws_profile" {
  description = "AWS profile."
  type        = string
  default     = "default"
}

variable "env" {
  description = "Environnement variables."
  type        = map(any)
  default     = {}
}
