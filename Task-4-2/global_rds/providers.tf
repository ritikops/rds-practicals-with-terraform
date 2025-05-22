terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
  }
}

# Primary Region Provider (Virginia)
provider "aws" {
  region = var.primary_region
  alias  = "primary"

  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
      Project     = "rds-global-failover"
    }
  }
}

# Replica Region Provider (Ireland)
provider "aws" {
  region = var.replica_region
  alias  = "replica"

  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
      Project     = "rds-global-failover"
    }
  }
}

provider "random" {}