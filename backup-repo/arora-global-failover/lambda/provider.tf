# provider "aws" {
#   alias = "primary"
# }

# provider "aws" {
#   alias = "secondary"
# }

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [aws.primary, aws.secondary]
    }
  }
}
