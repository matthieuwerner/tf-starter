
output "id" {
  value = docker_image.fpm-dev-gateway.id
}

output "url" {
  value = docker_container.fpm-dev-gateway.labels[1]
}

output "php_image" {
  value = docker_container.php-81-fpm-dev.image
}