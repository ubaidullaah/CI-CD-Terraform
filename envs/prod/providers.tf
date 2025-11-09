terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "GlueETLPipeline"
      Environment = "prod"
      ManagedBy   = "Terraform"
    }
  }
}
