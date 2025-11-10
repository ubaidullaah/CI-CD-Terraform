terraform {
  backend "s3" {
    bucket         = "terraform-state-glue-dev"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-glue-dev"
  }
}

# Trigger test plan