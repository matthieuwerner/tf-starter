
module "aws_module" {
  source = "aws_module"
}

output "aws" {
  value = "aws_module"
}

output "aws_module" {
  value = module.aws_module.aws_module
}
