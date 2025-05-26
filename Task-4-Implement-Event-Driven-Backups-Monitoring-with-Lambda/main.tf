# terraform {
#   required_version = ">= 1.3.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 4.55.0"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1" # Primary region
#   alias  = "primary"
# }

# provider "aws" {
#   region = "eu-west-1" # Secondary region
#   alias  = "replica"
# }

# module "primary" {
#   source = "./primary"
#   providers = {
#     aws = aws.primary
#   }
#   # Pass all required variables
#   global_cluster_id = var.global_cluster_id
#   db_identifier     = var.db_identifier
# }

# module "secondary" {
#   source = "./secondary"
#   providers = {
#     aws = aws.replica
#   }
#   # Pass all required variables
#   global_cluster_id = var.global_cluster_id
#   db_identifier     = var.db_identifier
#   depends_on        = [module.primary]
# }

# # module "monitoring" {
# #   source = "./monitoring"
# #   # Reference outputs from other modules
# #   primary_cluster_id    = module.primary.cluster_id
# #   primary_cluster_arn   = module.primary.cluster_arn
# #   secondary_cluster_id  = module.secondary.cluster_id
# #   secondary_cluster_arn = module.secondary.cluster_arn
# #   # Monitoring specific variables
# #   backup_bucket         = var.backup_bucket
# #   sns_topic_arn         = var.sns_topic_arn
# #   slack_webhook_url     = var.slack_webhook_url
# #   replica_lag_threshold = var.replica_lag_threshold
# # }
# module "monitoring" {
#   source = "./monitoring"

#   # Cluster references
#   primary_cluster_id    = module.primary.cluster_id
#   primary_cluster_arn   = module.primary.cluster_arn
#   secondary_cluster_id  = module.secondary.cluster_id
#   secondary_cluster_arn = module.secondary.cluster_arn

#   # Monitoring configuration
#   backup_bucket         = var.backup_bucket
#   sns_topic_arn         = var.sns_topic_arn
#   slack_webhook_url     = var.slack_webhook_url
#   replica_lag_threshold = var.replica_lag_threshold
# }

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "primary"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "secondary"
}

module "primary" {
  source = "./primary"
  providers = {
    aws = aws.primary
  }
  primary_cluster_id    = var.primary_cluster_id
  primary_cluster_arn   = var.primary_cluster_arn
  secondary_cluster_id  = var.secondary_cluster_id
  secondary_cluster_arn = var.secondary_cluster_arn
  global_cluster_id     = var.global_cluster_id
  db_identifier         = var.db_identifier
  # Add other required variables
}

module "secondary" {
  source = "./secondary"
  providers = {
    aws = aws.secondary
  }
  primary_cluster_id    = var.primary_cluster_id
  primary_cluster_arn   = var.primary_cluster_arn
  secondary_cluster_id  = var.secondary_cluster_id
  secondary_cluster_arn = var.secondary_cluster_arn
  global_cluster_id     = var.global_cluster_id
  db_identifier         = var.db_identifier
  # Add other required variables

  depends_on = [module.primary]
}

# module "monitoring" {
#   source = "./monitoring"

#   # Pass variables instead of module references
#   primary_cluster_id    = module.primary.cluster_id
#   primary_cluster_arn   = module.primary.cluster_arn
#   secondary_cluster_id  = module.secondary.cluster_id
#   secondary_cluster_arn = module.secondary.cluster_arn

#   backup_bucket         = var.backup_bucket
#   sns_topic_arn         = var.sns_topic_arn
#   slack_webhook_url     = var.slack_webhook_url
#   replica_lag_threshold = var.replica_lag_threshold
# }
module "monitoring" {
  source = "./monitoring"

  # Pass variables instead of module references
  primary_cluster_id    = module.primary.cluster_id
  primary_cluster_arn   = module.primary.cluster_arn
  secondary_cluster_id  = module.secondary.cluster_id
  secondary_cluster_arn = module.secondary.cluster_arn
  secondary_kms_key_arn = module.secondary.kms_key_arn
  primary_kms_key_arn   = module.primary.kms_key_arn

  backup_bucket         = var.backup_bucket
  sns_topic_arn         = var.sns_topic_arn
  slack_webhook_url     = var.slack_webhook_url
  replica_lag_threshold = var.replica_lag_threshold
}