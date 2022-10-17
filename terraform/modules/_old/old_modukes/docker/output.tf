
output "Frontend" {
  description = "Frontend URL"
  value       = "https://www.${var.project_domain}"
}

output "Postgres" {
  description = "Database informations"
  value       = docker_container.postgres.env
}
