
# ## Root module - main.tf

# module "rds_global_cluster" {
#   source = "./modules/rds"
# }

# module "lambda_monitoring" {
#   source                = "./modules/lambda"
#   snapshot_s3_bucket    = module.rds_global_cluster.snapshot_s3_bucket
#   rds_global_cluster_id = module.rds_global_cluster.global_cluster_id
#   sns_topic_arn         = module.notifications.sns_topic_arn
# }

# module "notifications" {
#   source = "./modules/notifications"
# }

# provider "aws" {
#   region = "us-east-1"
# }

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 4.0"
#     }
#   }
# }

module "rds" {
  source            = "./modules/rds"
  master_username   = var.master_username
  master_password   = var.master_password
  subnet_ids        = var.subnet_ids
  security_group_id = var.security_group_id
  azs               = var.azs
}

module "notifications" {
  source = "./modules/sns"
  email  = var.alert_email
}

module "lambda" {
  source                  = "./modules/lambda"
  snapshot_s3_bucket      = module.rds.snapshot_s3_bucket
  rds_global_cluster_id   = module.rds.global_cluster_id
  rds_instance_identifier = module.rds.rds_instance_identifier
  sns_topic_arn           = module.notifications.sns_topic_arn
  kms_key_id              = var.kms_key_id
  export_role_arn         = var.export_role_arn
}
