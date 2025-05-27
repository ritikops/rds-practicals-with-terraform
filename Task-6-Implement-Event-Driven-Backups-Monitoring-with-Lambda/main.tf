provider "aws" {
  region = var.primary_region
}

module "rds" {
  source           = "./modules/rds"
  cluster_name     = var.cluster_name
  primary_region   = var.primary_region
  secondary_region = var.secondary_region
  tags             = var.tags
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
