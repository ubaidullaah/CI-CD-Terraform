locals {
  role_name = "${var.project_name}-gha-oidc-${var.env}"
}

data "aws_iam_policy_document" "assume_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repo_owner}/${var.repo_name}:*"]
    }
  }
}

resource "aws_iam_role" "gha_role" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_oidc.json
  tags               = var.tags
}

# Backend state access for Terraform
data "aws_iam_policy_document" "state_access" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket}"]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket}/state/*"]
  }
  statement {
    actions   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.lock_table}"]
  }
}

resource "aws_iam_policy" "state_access" {
  name   = "${var.project_name}-gha-state-${var.env}"
  policy = data.aws_iam_policy_document.state_access.json
}

# Permissions for resources managed by this repo
# keep least privilege but allow creating and updating the glue role and buckets this stack names
data "aws_iam_policy_document" "managed_resources" {
  # iam for the glue execution role this stack manages
  statement {
    actions = [
      "iam:CreateRole","iam:DeleteRole","iam:GetRole","iam:PassRole",
      "iam:AttachRolePolicy","iam:DetachRolePolicy","iam:PutRolePolicy","iam:DeleteRolePolicy","iam:ListRolePolicies"
    ]
    resources = ["arn:aws:iam::${var.account_id}:role/${var.project_name}-glue-role-${var.env}"]
  }

  # glue job lifecycle
  statement {
    actions = [
      "glue:CreateJob","glue:UpdateJob","glue:DeleteJob","glue:GetJob","glue:GetJobs"
    ]
    resources = ["*"]
  }

  # s3 for buckets created by this stack. bucket names start with project_name and include env
  statement {
    actions   = [
      "s3:CreateBucket","s3:DeleteBucket","s3:PutBucketVersioning","s3:PutEncryptionConfiguration",
      "s3:PutBucketPolicy","s3:PutBucketTagging","s3:GetBucketLocation","s3:ListBucket"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "s3:ResourceAccount"
      values   = [var.account_id]
    }
  }

  statement {
    actions   = ["s3:PutObject","s3:GetObject","s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.project_name}-*/*"
    ]
  }
}

resource "aws_iam_policy" "managed_resources" {
  name   = "${var.project_name}-gha-managed-${var.env}"
  policy = data.aws_iam_policy_document.managed_resources.json
}

resource "aws_iam_role_policy_attachment" "attach_state" {
  role       = aws_iam_role.gha_role.name
  policy_arn = aws_iam_policy.state_access.arn
}

resource "aws_iam_role_policy_attachment" "attach_managed" {
  role       = aws_iam_role.gha_role.name
  policy_arn = aws_iam_policy.managed_resources.arn
}

