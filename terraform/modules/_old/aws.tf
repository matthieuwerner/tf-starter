
#provider "aws" {
#  region  = var.aws_region
#  profile = var.aws_profile
#}
#
## AWS environment
#module "aws" {
#  count = local.configuration.provider == "aws" ? 1 : 0
#
#  source = "./modules/aws"
#  // modules = local.modules
#}

#// Region informations
#data "aws_region" "current" {}
#
#output "current_region" {
#  value = data.aws_region.current.name
#}
#
#// Caller informations
#data "aws_caller_identity" "current" {}
#
#output "account_id" {
#  value = data.aws_caller_identity.current.account_id
#}
#
#output "caller_arn" {
#  value = data.aws_caller_identity.current.arn
#}
#
#output "caller_user" {
#  value = data.aws_caller_identity.current.user_id
#}

output "aws" {
  // formatlist: https://github.com/hashicorp/terraform/issues/8105
  // value = length(module.aws) > 0 ? module.aws[0].aws_module : "-"
  //value = [for k, v in module.aws : module.aws.docker_module.value ] // module.local[*].value
  value = ""
}