variable "project_name"      { type = string }
variable "env"               { type = string }
variable "glue_role_arn"     { type = string }
variable "scripts_bucket"    { type = string }
variable "data_bucket"       { type = string }
variable "number_of_workers" { type = number }
variable "worker_type"       { type = string }
variable "tags"              { type = map(string) }
