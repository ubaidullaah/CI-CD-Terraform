resource "aws_glue_job" "etl_job" {
  name     = "${var.project_name}-job-${var.env}"
  role_arn = var.glue_role_arn

  command {
    name            = "glueetl"
    script_location = "s3://${var.scripts_bucket}/glue_jobs/etl_basic.py"
    python_version  = "3"
  }

  glue_version        = "4.0"
  number_of_workers   = var.number_of_workers
  worker_type         = var.worker_type
  timeout             = 60
  max_retries         = 1

  default_arguments = {
    "--TempDir"                   = "s3://${var.data_bucket}/temp/"
    "--JOB_NAME"                  = "${var.project_name}-job-${var.env}"
    "--RAW_PATH"                  = "s3://${var.data_bucket}/raw/"
    "--PROCESSED_PATH"            = "s3://${var.data_bucket}/processed/"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"            = "true"
    "--job-bookmark-option"       = "job-bookmark-enable"
    "--enable-glue-datacatalog"   = "true"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  tags = var.tags
}

output "glue_job_name" { value = aws_glue_job.etl_job.name }
