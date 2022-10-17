
variable "name" {
  description = "Name of the function."
  type        = string
}

variable "domain" {
  description = "Local domain name."
  type        = string
}

variable "network" {
  description = "Current network."
  type        = string
}

variable "php_version" {
  description = "PHP version."
  type        = string
  default     = "8.1"

  validation {
    condition     = contains(["7.2", "7.3", "7.4", "8.0", "8.1"], var.php_version)
    error_message = "PHP version should be \"7.2\", \"7.3\", \"7.4\", \"8.0\" or \"8.1\"."
  }
}

variable "application_path" {
  description = "Application path, relative to terraform root folder (example: \"../application\")."
  type        = string
}

variable "document_root" {
  description = "Document root, relative to \"application_path\" (example: \"public\")."
  type        = string
  default     = "public"
}

variable "handler" {
  description = "Handler, relative to \"application_path\" (example: \"public/index.php\")."
  type        = string
  default     = "public/index.php"
}
