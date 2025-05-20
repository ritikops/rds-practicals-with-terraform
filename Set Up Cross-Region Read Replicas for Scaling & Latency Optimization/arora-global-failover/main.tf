# module "vpc" {
#   source           = "./vpc"
#   primary_region   = var.primary_region
#   secondary_region = var.secondary_region
# }

# module "aurora" {
#   source             = "./aurora"
#   db_engine          = var.db_engine
#   engine_version     = var.engine_version
#   instance_class     = var.instance_class
#   db_name            = var.db_name
#   db_username        = var.db_username
#   db_password        = var.db_password
#   global_cluster_id  = var.global_cluster_id
# }

# module "lambda" {
#   source            = "./lambda"
#   primary_region    = var.primary_region
#   secondary_region  = var.secondary_region
#   global_cluster_id = var.global_cluster_id
#   hosted_zone_id    = var.hosted_zone_id
#   db_hostname       = var.db_hostname
# }

# module "route53" {
#   source         = "./route53"
#   hosted_zone_id = var.hosted_zone_id
#   db_hostname    = var.db_hostname
# }

# module "cloudwatch" {
#   source            = "./cloudwatch"
#   global_cluster_id = var.global_cluster_id
# }
