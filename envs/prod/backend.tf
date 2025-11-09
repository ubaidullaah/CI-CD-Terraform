terraform {
  backend "s3" {
    bucket         = "terraform-state-glue-prod"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-glue-prod"
  }
}
