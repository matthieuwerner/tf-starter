[![tf-starter tests suite](https://github.com/matthieuwerner/tf-starter/actions/workflows/workflow.yaml/badge.svg)](https://github.com/matthieuwerner/tf-starter/actions/workflows/workflow.yaml)

## Introduction

This project has been created to bootstrap your PHP project (Symfony, Laravel, Api Platform, or whatever ...) with Terraform.

Install dependencies and run the **start** command **to have a full PHP stack running locally** 🥳.
Local configuration is described via the [Docker provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs) 
in the **terraform/docker** directory. 

After that, just run **deploy-[provider]** command to build your stack on your favorite provider.
AWS-Lambda is for now the only available provider. 

This project compile stuff from [JoliCode Docker Starter](https://github.com/jolicode/docker-starter),
 [Bref.sh](https://bref.sh/) layers and [Terraform learning resources](https://learn.hashicorp.com/terraform).

😎 **Pssst: Use this project as a Github template**

## Quickstart 🚄

Install the following dependencies:
- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) 
- [make](https://en.wikipedia.org/wiki/Make_(software))

Replace variables in `Makefle`:
```Makefile
export TF_VAR_project_name=terraform
export TF_VAR_project_domain=terraform.test
export TF_VAR_php_version=8.1
```

You can additionally add context or custom variables in your `terraform/docker/variables.tfvars`:
```terraform
env = {                              # Environnement variables
  APP_NAME  = "tf-starter"
  APP_DEBUG = true
  APP_ENV   = "prod"
}
```

Replace variables in `terraform/docker/variables.tfvars`:
```terraform
project_name      = "terraform"      # Your project name, used as a prefix of images and containers
project_domain    = "terraform.test" # The local domain
php_version       = "8.1"            # The PHP version to use

env = {                              # Environnement variables
  APP_NAME  = "tf-starter"
  APP_DEBUG = true
  APP_ENV   = "prod"
}
```

Configure your local host in the **/etc/hosts** file:
```
# Use the same domain as "project_domain" in the previous block
echo "127.0.0.1 terraform.test www.terraform.test" >> /etc/hosts
```

_You optionally can install your favorite framework with [installers](#installers):_
```bash
make install-symfony
```

Start the local stack:
```
make start
```

Go to your `project_domain`, you should now see your website content.

To configure deployment, you now have to read the appropriate section:
- [AWS - Lambda](#AWS---Lambda)

## Providers

### AWS - Lambda

AWS Lambda provider use Bref.sh layers on top of AWS Lambda.

#### Quickstart

Replace or add variables in `terraform/aws/variables.tfvars` if needed:
```terraform
env = {
  DEFAULT_REGION = "eu-west-3"
  APP_NAME       = "tf-starter"
  APP_DEBUG      = true
  APP_ENV        = "prod"
}
```

Deploy your application:
```
make lambda-deploy
```

This will output something like :

```bash
Apply complete! Resources: x added, x changed, x destroyed.

Outputs:

base_url = "https://**********.execute-api.eu-west-3.amazonaws.com/"
function_name = "terraform"
lambda_bucket_name = "terraform-dev"
```

Go to the provided **base_url**, you should now see an :
```
Hello world!
```

#### Variables

`project_name`: Project name used as function name.

`php_layer`: Bref.sh layer arn for your PHP version. The layer have to be in the same region
as your lambda. You will find a complete list here: https://bref.sh/docs/runtimes/index.html#lambda-layers-in-details

`entrypoint`: The entrypoint of your script. Default is `public/index.php`.

`aws_region`: AWS region. Default is `eu-west-3`.

`aws_profile`: AWS profile. Default is `default`.

`env`: Environment variables as an object. Ex: `{FOO = "BAR"}`

## Cookbook 🤠

To go further ... (and you will)

### Installers

Use **installers** to initialize the `application` folder with your favorite framework.

*⚠ It will clear the "application" folder content, and backup the old one with .old exentension.*

#### Install Symfony

```bash
make install-symfony
```

Continue the magic with the [maker bundle](https://symfony.com/bundles/SymfonyMakerBundle/current/index.html).
Example:
```bash
make builder
cd application
bin/console make:controller
```

#### Install API Platform

```bash
make install-apip
```

#### Install Laravel

```bash
make install-laravel
```

### Add more services

<details>
<summary>Elasticsearch</summary>

#### Local stack

Add the following code to `terraform/docker/resources.tf`:
```terraform
// Elasticsearch --------------------------------
resource "docker_image" "elasticsearch" {
  name = "elasticsearch:7.16.2"
}

resource "docker_container" "elasticsearch" {
  name  = "${var.project_name}_elasticsearch"
  image = docker_image.elasticsearch.latest
  network_mode = "tf-starter_network"
  env = ["discovery.type=single-node"]
  volumes {
    volume_name = "elasticsearch-data"
    container_path = "/usr/share/elasticsearch/data"
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-elasticsearch.rule"
    value = "Host(`elasticsearch.${var.project_domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-elasticsearch.tls"
    value = "true"
  }
}

resource "docker_image" "kibana" {
  name = "kibana:7.16.2"
}

resource "docker_container" "kibana" {
  name  = "${var.project_name}_kibana"
  image = docker_image.kibana.latest
  depends_on = [docker_container.elasticsearch]
  network_mode = "tf-starter_network"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-kibana.rule"
    value = "Host(`kibana.${var.project_domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-kibana.tls"
    value = "true"
  }
}
```

Add the following code to `terraform/docker/output.tf`:
```terraform
output "Elasticsearch" {
  description = "Elasticsearch informations"
  value="https://elasticsearch.${var.project_domain}"
}

output "Kibana" {
  description = "Elasticsearch informations"
  value="https://kibana.${var.project_domain}"
}
```

#### Provider: AWS Lambda

Add the following code to `terraform/aws-lambda/resources.tf`:
```terraform
resource "aws_elasticsearch_domain" "es" {
  domain_name = local.elk_domain
  elasticsearch_version = "7.7"

  cluster_config {
      instance_count = 3
      instance_type = "r5.large.elasticsearch"
      zone_awareness_enabled = true

      zone_awareness_config {
        availability_zone_count = 3
      }
  }

  vpc_options {
      subnet_ids = [
        aws_subnet.nated_1.id,
        aws_subnet.nated_2.id,
        aws_subnet.nated_3.id
      ]

      security_group_ids = [
          aws_security_group.es.id
      ]
  }

  ebs_options {
      ebs_enabled = true
      volume_size = 10
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "es:*",
          "Principal": "*",
          "Effect": "Allow",
          "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.elk_domain}/*"
      }
  ]
}
  CONFIG

  snapshot_options {
      automated_snapshot_start_hour = 23
  }

  tags = {
      Domain = local.elk_domain
  }
}
```

Add the following code to `terraform/aws-lambda/output.tf`:
```terraform
output "elk_endpoint" {
  value = aws_elasticsearch_domain.es.endpoint
}

output "elk_kibana_endpoint" {
  value = aws_elasticsearch_domain.es.kibana_endpoint
}
```

</details>

<details>
<summary>Redis</summary>

#### Local stack

Add the following code to `terraform/docker/resources.tf`:
```terraform
// Redis --------------------------------
resource "docker_image" "redis" {
  name = "redis:6.2"
}

resource "docker_container" "redis" {
  name  = "${var.project_name}_redis"
  image = docker_image.redis.latest
  network_mode = "tf-starter_network"
  volumes {
    volume_name = "redis-data"
    container_path = "/data"
  }
}

resource "docker_image" "redis-insight" {
  name = "redislabs/redisinsight"
}

resource "docker_container" "redis-insight" {
  name  = "${var.project_name}_redis_insight"
  image = docker_image.redis-insight.latest
  depends_on = [docker_container.redis]
  network_mode = "tf-starter_network"
  volumes {
    volume_name = "redis-insight-data"
    container_path = "/db"
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-redis.rule"
    value = "Host(`redis.${var.project_domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-redis.tls"
    value = "true"
  }
}
```

Add the following code to `terraform/docker/output.tf`:
```terraform
output "Redis" {
  description = "Redis informations"
  value="https://redis.${var.project_domain}"
}
```

#### Provider: AWS Lambda

Add the following layer (match layer-version and region with https://raw.githubusercontent.com/brefphp/extra-php-extensions/master/layers.json):

```terraform
arn:aws:lambda:<region>:403367587399:layer:redis-php-81:<layer-version>

# ex: arn:aws:lambda:eu-west-3:403367587399:layer:redis-php-81:4
```

</details>

<details>
<summary>RabbitMQ</summary>

#### Local stack

Add the following code to `terraform/docker/resources.tf`:
```terraform
// RabbitMQ --------------------------------
resource "docker_image" "rabbitmq" {
  name = "rabbitmq:3.9-management-alpine"
}

resource "docker_container" "rabbitmq" {
  name  = "${var.project_name}_redis_insight"
  image = docker_image.rabbitmq.latest
  network_mode = "tf-starter_network"
  env = ["RABBITMQ_VM_MEMORY_HIGH_WATERMARK=1024MiB"]
  volumes {
    volume_name = "rabbitmq-data"
    container_path = "/var/lib/rabbitmq"
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-rabbitmq.rule"
    value = "Host(`rabbitmq.${var.project_domain}`)"
  }
  labels {
    label = "traefik.http.routers.${var.project_name}-rabbitmq.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.services.rabbitmq.loadbalancer.server.port"
    value = "15672"
  }
}
```

Add the following code to `terraform/docker/output.tf`:
```terraform
output "Rabbitmq" {
  description = "Rabbitmq informations"
  value="https://rabbitmq.${var.project_domain}"
}
```

#### Provider: AWS Lambda

Add the following layer (match layer-version and region with https://raw.githubusercontent.com/brefphp/extra-php-extensions/master/layers.json):

```terraform
arn:aws:lambda:<region>:403367587399:layer:amqp-php-80:<layer-version>

# ex: arn:aws:lambda:eu-west-3:403367587399:layer:amqp-php-80:4
```

</details>

### Manage environments

There are a lot a way to deal with multiple environments like preprod or prod.
If your stack are basically similar between environments, you could create one [workspace](https://www.terraform.io/language/state/workspaces) 
for each.

```bash
# Create a preprod workspace
terraform workspace new preprod

# Create a prod workspace
terraform workspace new prod

# List workspaces
terraform workspace list
```

After that, create in your provider working directory an `environment` folder with
2 tfvars files, named as your workspaces.
(`ex: aws-lambda/environment/preprod.tfvars.`).

Edit your Makefile commands for chosen provider and replace ` -var-file=variables.tfvars` by
`-var-file=environment/$$(terraform workspace show).tfvars`.

Now you juste have to adapt your .tfvars files by environment, and navigate 
between your workspaces with:
```bash
# To use "prod" environment
terraform workspace select prod
```

Your commands will now automatically use the variable configuration who match the current workspace 🙌🏻. 

### Cleanup the mess

After initialization, you can (should) safely remove useless providers, installer commands, replace the readme, etc.

---
```
Usefull stuff used in this repo (thanks to them):
- Docker starter: https://github.com/jolicode/docker-starter
- Bref.sh: https://bref.sh/
- TF learning respources: https://learn.hashicorp.com/terraform
- Makefile tips: https://gist.github.com/prwhite/8168133?permalink_comment_id=3785627#gistcomment-3785627
```