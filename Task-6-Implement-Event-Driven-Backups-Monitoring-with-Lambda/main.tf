
## Root module - main.tf

module "rds_global_cluster" {
  source = "./modules/rds"
}

module "lambda_monitoring" {
  source                = "./modules/lambda"
  snapshot_s3_bucket    = module.rds_global_cluster.snapshot_s3_bucket
  rds_global_cluster_id = module.rds_global_cluster.global_cluster_id
  sns_topic_arn         = module.notifications.sns_topic_arn
}

module "notifications" {
  source = "./modules/notifications"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
