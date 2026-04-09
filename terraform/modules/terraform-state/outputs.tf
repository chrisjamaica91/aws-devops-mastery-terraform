# ==========================================
# Outputs
# ==========================================

output "s3_bucket_id" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking (deprecated - use S3 native locking)"
  value       = try(aws_dynamodb_table.terraform_lock[0].name, null)
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN (deprecated - use S3 native locking)"
  value       = try(aws_dynamodb_table.terraform_lock[0].arn, null)
}

output "backend_config" {
  description = "Backend configuration for use in environment configs"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "infrastructure/terraform.tfstate"
    region         = data.aws_region.current.name
    encrypt        = true
    use_lockfile   = true  # S3 native locking (modern approach)
    # dynamodb_table is deprecated - only populated if enable_dynamodb_locking = true
    dynamodb_table = try(aws_dynamodb_table.terraform_lock[0].name, null)
  }
}