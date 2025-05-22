# provider "aws" {
#   alias  = "primary"
#   region = var.primary_region
# }

# provider "aws" {
#   alias  = "secondary"
#   region = var.secondary_region
# }

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [aws.primary, aws.secondary]
    }
  }
}
