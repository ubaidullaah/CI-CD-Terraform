data "aws_iam_policy_document" "glue_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "${var.project_name}-glue-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "glue_s3_access" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.scripts_bucket_arn, var.data_bucket_arn]
  }

  statement {
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "${var.scripts_bucket_arn}/*",
      "${var.data_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "glue_s3_access" {
  name   = "${var.project_name}-glue-s3-${var.env}"
  policy = data.aws_iam_policy_document.glue_s3_access.json
}

resource "aws_iam_role_policy_attachment" "managed_glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "managed_cw_logs" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}
