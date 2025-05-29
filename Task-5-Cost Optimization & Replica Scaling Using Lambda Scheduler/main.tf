# module "vpc" {
#   source = "./modules/vpc"
#   vpc_cidr = "10.0.0.0/16"
#   private_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
# }

# module "rds" {
#   source = "./modules/rds"
#   db_username = var.db_username
#   db_password = var.db_password
#   db_name     = "mydb"
#   db_instance_class = "db.t3.medium"
#   initial_read_replica_count = 1
#   db_sg_id = module.vpc.db_sg_id
#   subnet_group_name = module.vpc.subnet_group_name
# }

# module "iam" {
#   source = "./modules/iam"
# }

# module "lambda" {
#   source       = "./modules/lambda"
#   role_arn     = module.iam.lambda_role_arn
#   handler_file = "${path.root}/lambda/scheduler.py"
#   db_cluster_id = module.rds.db_cluster_id
# }

# module "cloudwatch" {
#   source     = "./modules/cloudwatch"
#   lambda_arn = module.lambda.lambda_arn
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

# VPC Module
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# RDS Module
module "rds" {
  source                     = "./modules/rds"
  db_username                = var.db_username
  db_password                = var.db_password
  subnet_ids                 = module.vpc.private_subnet_ids
  db_name                    = "mydb"
  db_instance_class          = "db.t3.medium"
  initial_read_replica_count = 1
  db_sg_id                   = module.vpc.db_sg_id
  subnet_group_name          = module.vpc.subnet_group_name
}

# IAM Module (for Lambda Role)
module "iam" {
  source = "./modules/iam"
}

# Lambda Module (Scheduler)
module "lambda" {
  source         = "./modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn
  db_cluster_id  = module.rds.db_cluster_id
  scale_up_event_rule_arn = module.cloudwatch.scale_up_event_rule_arn
  scale_down_event_rule_arn = module.cloudwatch.scale_down_event_rule_arn
  lambda_exec_role_arn = module.iam.lambda_exec_role_arn
  sns_topic_arn = module.lambda.sns_topic_arn
  endpoint = module.rds.endpoint
}

# CloudWatch Scheduler Trigger
module "cloudwatch" {
  source     = "./modules/cloudwatch"
  lambda_name = module.lambda.lambda_name
  lambda_arn = module.lambda.lambda_arn
}
