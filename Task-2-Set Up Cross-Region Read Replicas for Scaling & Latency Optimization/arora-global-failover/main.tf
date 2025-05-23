module "vpc" {
  source = "./vpc"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  primary_region   = var.primary_region
  secondary_region = var.secondary_region
}

module "aurora" {
  source = "./aurora"
  # providers = {
  #   aws.primary   = aws.primary
  #   aws.secondary = aws.secondary
  # }
  primary_region      = var.primary_region
  secondary_region    = var.secondary_region
  db_password         = var.db_password
  global_cluster_id   = var.global_cluster_id
  subnet_ids           = module.vpc.primary_subnet_ids
  primary_subnet_ids   = module.vpc.primary_subnet_ids
  secondary_subnet_ids = module.vpc.secondary_subnet_ids
  secondary_vpc_id = module.vpc.secondary_vpc_id
  
}

# Repeat for lambda, cloudwatch, route53 modules if they use aliased providers

module "lambda" {
  source = "./lambda"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  primary_region    = var.primary_region
  secondary_region  = var.secondary_region
  global_cluster_id = var.global_cluster_id
  primary_cluster_identifier = module.aurora.primary_cluster_identifier
  replica_cluster_identifier = module.aurora.replica_cluster_identifier
  global_cluster_identifier = module.aurora.global_cluster_identifier
  replica_region     = var.secondary_region
  secondary_cluster_id = module.aurora.secondary_cluster_id
  hosted_zone_id    = var.hosted_zone_id
  db_hostname       = var.db_hostname
  function_name     = var.function_name
}

module "cloudwatch" {
  source = "./cloudwatch"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  global_cluster_id    = var.global_cluster_id
  lambda_function_arn  = module.lambda.failover_lambda_arn
  lambda_function_name = module.lambda.failover_lambda_name
  primary_health_check_id = module.route53.primary_health_check_id
}

module "route53" {
  source = "./route53"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  hosted_zone_id      = var.hosted_zone_id
  db_hostname         = var.db_hostname
  primary_endpoint    = module.aurora.primary_endpoint
  secondary_endpoint  = module.aurora.secondary_endpoint
}
