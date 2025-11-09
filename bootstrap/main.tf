locals {
  dev_bucket  = "terraform-state-glue-dev"
  prod_bucket = "terraform-state-glue-prod"
  dev_table   = "terraform-locks-glue-dev"
  prod_table  = "terraform-locks-glue-prod"
}

resource "aws_s3_bucket" "state_dev" {
  bucket        = local.dev_bucket
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "state_dev_v" {
  bucket = aws_s3_bucket.state_dev.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket" "state_prod" {
  bucket        = local.prod_bucket
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "state_prod_v" {
  bucket = aws_s3_bucket.state_prod.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_dynamodb_table" "locks_dev" {
  name         = local.dev_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "locks_prod" {
  name         = local.prod_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "state_buckets" {
  value = {
    dev  = aws_s3_bucket.state_dev.bucket
    prod = aws_s3_bucket.state_prod.bucket
  }
}

output "lock_tables" {
  value = {
    dev  = aws_dynamodb_table.locks_dev.name
    prod = aws_dynamodb_table.locks_prod.name
  }
}

