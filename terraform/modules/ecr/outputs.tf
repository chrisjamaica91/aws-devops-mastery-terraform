# ==========================================
# ECR Module Outputs
# ==========================================

output "repository_urls" {
  description = "Map of service names to ECR repository URLs"
  value = {
    for k, v in aws_ecr_repository.service :
    k => v.repository_url
  }
}

output "repository_arns" {
  description = "Map of service names to ECR repository ARNs"
  value = {
    for k, v in aws_ecr_repository.service :
    k => v.arn
  }
}

output "repository_registry_ids" {
  description = "Map of service names to ECR registry IDs"
  value = {
    for k, v in aws_ecr_repository.service :
    k => v.registry_id
  }
}

output "repository_names" {
  description = "List of ECR repository names"
  value       = [for repo in aws_ecr_repository.service : repo.name]
}

# Convenience outputs for CI/CD
output "javascript_api_url" {
  description = "ECR URL for JavaScript API service"
  value       = try(aws_ecr_repository.service["javascript-api"].repository_url, null)
}

output "java_service_url" {
  description = "ECR URL for Java service"
  value       = try(aws_ecr_repository.service["java-service"].repository_url, null)
}

output "rust_processor_url" {
  description = "ECR URL for Rust processor service"
  value       = try(aws_ecr_repository.service["rust-processor"].repository_url, null)
}