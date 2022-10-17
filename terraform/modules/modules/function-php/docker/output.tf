
output "id" {
  value = docker_image.fpm-dev-gateway.id
}

output "url" {
  value = docker_container.fpm-dev-gateway.labels
}

output "php_image" {
  value = docker_container.php-fpm.image
}
