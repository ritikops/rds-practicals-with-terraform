
module "global_database" {
  source = "./modules/global-database"

  providers = {
    aws.primary = aws.primary
    aws.replica = aws.replica
  }

  cluster_identifier     = var.cluster_identifier
  primary_region         = var.primary_region
  replica_region         = var.replica_region
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
}

module "dns_failover" {
  source = "./modules/dns-failover"

  providers = {
    aws.primary = aws.primary
    aws.replica = aws.replica
  }

  cluster_identifier = var.cluster_identifier
  domain_name        = var.domain_name
  primary_region     = var.primary_region
  replica_region     = var.replica_region
  global_cluster_arn = module.global_database.global_cluster_arn
}

module "failover_monitoring" {
  source = "./modules/failover-monitoring"

  providers = {
    aws.primary = aws.primary
    aws.replica = aws.replica
  }

  cluster_identifier = var.cluster_identifier
  global_cluster_id  = module.global_database.global_cluster_id
  primary_arn        = module.global_database.primary_cluster_arn
  replica_arn        = module.global_database.replica_cluster_arn
  sns_topic_arn      = var.sns_topic_arn
  slack_webhook_url  = var.slack_webhook_url
}