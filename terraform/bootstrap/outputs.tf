# ==========================================
# Outputs
# ==========================================

# OIDC outputs
output "oidc_provider_arn" {
  description = "GitHub OIDC Provider ARN"
  value       = module.github_oidc.oidc_provider_arn
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions - use this in workflows"
  value       = module.github_oidc.role_arn
}

# State infrastructure outputs
output "dev_state_bucket" {
  description = "Dev environment state bucket"
  value       = module.terraform_state_dev.s3_bucket_id
}

output "dev_lock_table" {
  description = "Dev environment lock table"
  value       = module.terraform_state_dev.dynamodb_table_name
}

output "staging_state_bucket" {
  description = "Staging environment state bucket"
  value       = module.terraform_state_staging.s3_bucket_id
}

output "staging_lock_table" {
  description = "Staging environment lock table"
  value       = module.terraform_state_staging.dynamodb_table_name
}

output "production_state_bucket" {
  description = "Production environment state bucket"
  value       = module.terraform_state_production.s3_bucket_id
}

output "production_lock_table" {
  description = "Production environment lock table"
  value       = module.terraform_state_production.dynamodb_table_name
}

# Backend configurations for easy copy-paste
output "backend_config_dev" {
  description = "Copy this into dev backend configuration"
  value       = module.terraform_state_dev.backend_config
}

output "backend_config_staging" {
  description = "Copy this into staging backend configuration"
  value       = module.terraform_state_staging.backend_config
}

output "backend_config_production" {
  description = "Copy this into production backend configuration"
  value       = module.terraform_state_production.backend_config
}
