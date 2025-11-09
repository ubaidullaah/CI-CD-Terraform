data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "scripts" {
  bucket        = "${var.project_name}-glue-scripts-${var.env}-${substr(data.aws_caller_identity.current.account_id, 0, 8)}"
  force_destroy = true
  tags          = merge(var.tags, { Name = "${var.project_name}-scripts-${var.env}" })
}

resource "aws_s3_bucket_versioning" "scripts_versioning" {
  bucket = aws_s3_bucket.scripts.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "scripts_encryption" {
  bucket = aws_s3_bucket.scripts.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket" "data" {
  bucket        = "${var.project_name}-data-${var.env}-${substr(data.aws_caller_identity.current.account_id, 0, 8)}"
  force_destroy = true
  tags          = merge(var.tags, { Name = "${var.project_name}-data-${var.env}" })
}

resource "aws_s3_bucket_versioning" "data_versioning" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_encryption" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

output "scripts_bucket" { value = aws_s3_bucket.scripts.bucket }
output "data_bucket"    { value = aws_s3_bucket.data.bucket }
