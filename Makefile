
# !! Set here your project configuration !!
export TF_VAR_project_name=terraform
export TF_VAR_project_domain=terraform.test
export TF_VAR_php_version=8.1

# Commands
TERRAFORM?=DOCKER_BUILDKIT=1 terraform
TERRAFORM_FOLDER = terraform
DOCKER_EXEC?=docker exec -it -u app
DOCKER_RUN?=docker run -it -u app --rm
BUILDER?=$(DOCKER_RUN) -v "${PWD}:/home/app/application" \
	-v "${COMPOSER_CACHE_DIR}:/home/app/.composer/cache" \
	-v "builder-data:/home/app" \
	builder

# Help command
.DEFAULT_GOAL := help
.PHONY: help
help: ## Display commands list
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## Local stack:
start: ## Build & start containers
	terraform -chdir=$(TERRAFORM_FOLDER)/docker init -var-file=variables.tfvars
	terraform -chdir=$(TERRAFORM_FOLDER)/docker apply -var-file=variables.tfvars -auto-approve

stop: ## Stop containers
	docker stop $$(docker container ls -q --filter name=$(TF_VAR_project_name))

restart: ## Restart containers
	docker restart $$(docker container ls -q --filter name=$(TF_VAR_project_name))

builder: ## Start terminal on the "builder" container as "app"
	$(BUILDER) /bin/bash

logs: ## Show local logs
	docker ps -q | xargs -L 1 docker logs

reset: destroy start ## Destroy images and containers and restart the stack

destroy: ## Destroy images and containers
	terraform -chdir=$(TERRAFORM_FOLDER)/docker destroy -auto-approve

## Project specific:
install: ## Install dependencies.
	$(BUILDER) composer --working-dir=application install

optimize: ## Optimize dependencies for production.
	rm -rf vendor
	$(BUILDER) composer --working-dir=application install --prefer-dist --optimize-autoloader --no-dev

update: ## Update dependencies.
	$(BUILDER) composer --working-dir=application update

cs_fix:
	$(BUILDER) php-cs-fixer fix application --rules=@PhpCsFixer,@PHP81Migration --diff --no-interaction

## Provider: AWS - Lambda
lambda-deploy: ## Deploy application in a AWS Lambda environment .
	terraform -chdir=$(TERRAFORM_FOLDER)/aws-lambda init -var-file=variables.tfvars -reconfigure -upgrade
	terraform -chdir=$(TERRAFORM_FOLDER)/aws-lambda apply -var-file=variables.tfvars

lambda-get-url: ## Get URL of the Lambda.
	terraform -chdir=$(TERRAFORM_FOLDER)/aws-lambda output -raw base_url

lambda-show-bucket: ## Show the Lambda bucket content.
	aws s3 ls $(terraform output -raw lambda_bucket_name)

## Installers:
install-symfony: ## Install Symfony
	$(BUILDER) mv application application.old
	$(BUILDER) composer create-project --no-interaction --verbose symfony/website-skeleton application "^5.4"
	$(BUILDER) composer require --working-dir=application --no-interaction "bref/bref" "bref/extra-php-extensions" "bref/symfony-bridge"
	$(BUILDER) sed -i 's#DATABASE_URL.*#DATABASE_URL=postgresql://app:app@postgres:5432/app\?serverVersion=12\&charset=utf8#' application/.env
	$(MAKE) restart

install-apip: ## Install API Platform
	$(BUILDER) mv application application.old
	$(BUILDER) composer create-project --no-interaction --verbose symfony/website-skeleton application "^5.4"
	$(BUILDER) composer require --working-dir=application --no-interaction "api" "bref/bref" "bref/extra-php-extensions" "bref/symfony-bridge"
	$(MAKE) restart

install-laravel: ## Install Laravel
	$(BUILDER) mv application application.old
	$(BUILDER) composer create-project --no-interaction --verbose laravel/laravel application
	$(BUILDER) composer require --working-dir=application --no-interaction "bref/bref" "bref/extra-php-extensions" "bref/laravel-bridge"
	$(MAKE) restart

## Tests:
terraform-lint: ## Check Terraform syntax
	terraform fmt -check -recursive

cs_check:
	$(BUILDER) php-cs-fixer fix application --rules=@PhpCsFixer,@PHP81Migration --diff --no-interaction --dry-run

phpstan:
	$(BUILDER) phpstan analyze --level=max application
