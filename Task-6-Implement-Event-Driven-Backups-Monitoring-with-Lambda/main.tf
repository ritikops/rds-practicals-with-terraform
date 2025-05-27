
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.primary_region
}
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id

}
module "rds" {
  source                           = "./modules/rds"
  cluster_name                     = var.cluster_name
  primary_region                   = var.primary_region
  secondary_region                 = var.secondary_region
  global_cluster_identifier        = var.global_cluster_identifier
  tags                             = var.tags
  secondary_vpc_security_group_ids = [data.aws_security_group.default.id] # Required arguments you are missing:
  secondary_instance_class         = "db.r6g.large"
  # secondary_vpc_security_group_ids = "default"
  engine_version                  = "8.0.mysql_aurora.3.04.0"
  secondary_db_subnet_group_name  = "your-secondary-subnet-group"
  db_cluster_parameter_group_name = "your-cluster-parameter-group"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.snapshot_bucket_name
  tags        = var.tags
}

module "sns" {
  source     = "./modules/sns"
  topic_name = var.topic_name
  tags       = var.tags
}

module "iam" {
  source           = "./modules/iam"
  lambda_role_name = var.lambda_role_name
  s3_bucket_arn    = module.s3.bucket_arn
  sns_topic_arn    = module.sns.topic_arn
  tags             = var.tags
}

module "lambda" {
  source        = "./modules/lambda"
  function_name = var.lambda_function_name
  role_arn      = module.iam.lambda_role_arn
  bucket_name   = module.s3.bucket_name
  sns_topic_arn = module.sns.topic_arn
  tags          = var.tags
}

module "eventbridge" {
  source     = "./modules/eventbridge"
  lambda_arn = module.lambda.lambda_arn
  tags       = var.tags
}
