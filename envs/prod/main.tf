locals {
  project_name = "glue-etl"
  env          = "prod"
  tags = {
    Project     = local.project_name
    Environment = local.env
    ManagedBy   = "Terraform"
    
  }
    # add these locals inside the existing locals block
  repo_owner   = "ubaidullaah"
  repo_name    = "CI-CD-Terraform"
  account_id   = "973516475030"
  region       = "us-east-1"

  state_bucket = "terraform-state-glue-prod"
  lock_table   = "terraform-locks-glue-prod"

  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"

}

module "s3_data" {
  source       = "../../modules/s3_data"
  project_name = local.project_name
  env          = local.env
  tags         = local.tags
}

module "iam_glue" {
  source             = "../../modules/iam_glue"
  project_name       = local.project_name
  env                = local.env
  tags               = local.tags
  scripts_bucket_arn = module.s3_data.scripts_bucket_arn
  data_bucket_arn    = module.s3_data.data_bucket_arn
}

module "glue_job" {
  source            = "../../modules/glue_job"
  project_name      = local.project_name
  env               = local.env
  glue_role_arn     = module.iam_glue.role_arn
  scripts_bucket    = module.s3_data.scripts_bucket
  data_bucket       = module.s3_data.data_bucket
  number_of_workers = 5
  worker_type       = "G.2X"
  tags              = local.tags
}

resource "aws_s3_object" "job_script" {
  bucket = module.s3_data.scripts_bucket
  key    = "glue_jobs/etl_basic.py"
  source = "../../scripts/glue_jobs/etl_basic.py"
  etag   = filemd5("../../scripts/glue_jobs/etl_basic.py")
}
# add this module block near the end of the file
module "ci_role" {
  source            = "../../modules/ci_role"
  project_name      = local.project_name
  env               = local.env
  repo_owner        = local.repo_owner
  repo_name         = local.repo_name
  oidc_provider_arn = local.oidc_provider_arn
  state_bucket      = local.state_bucket
  lock_table        = local.lock_table
  region            = local.region
  account_id        = local.account_id
  tags              = local.tags
}


#