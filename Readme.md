# Terraform AWS Glue with GitHub Actions CI

This project provisions AWS Glue infrastructure with Terraform and automates Terraform Plan and Apply using GitHub Actions and approvals.

### Branches
- `master`: Production  
- `dev`: Development  
- `feature/*`: Feature work branching from `dev`

### CI/CD Flow
1. PR to `dev`: Runs `terraform plan` (no apply).  
2. Merge to `dev`: Runs `terraform apply` for `envs/dev` (requires manual approval).  
3. PR to `master`: Runs `terraform plan` for production.  
4. Merge to `master`: Runs `terraform apply` for `envs/prod` (requires manual approval).

### Setup in GitHub
- Create environments: `dev`, `prod`  
- Add reviewers to each  
- Add secrets:  
  - `AWS_ROLE_TO_ASSUME_DEV`  
  - `AWS_ROLE_TO_ASSUME_PROD`  
- Add variables:  
  - `AWS_REGION = us-east-1`  
  - `TF_CLI_ARGS_init = -upgrade`

### Local run
```bash
cd envs/dev
terraform init
terraform apply -auto-approve
