# ==========================================
# Dev Environment Outputs
# ==========================================

# ==========================================
# General
# ==========================================

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

# ==========================================
# VPC Outputs
# ==========================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# ==========================================
# EKS Outputs
# ==========================================

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "karpenter_node_instance_profile_name" {
  description = "Karpenter node instance profile name"
  value       = module.eks.karpenter_node_instance_profile_name
}

output "karpenter_controller_role_arn" {
  description = "Karpenter controller IAM role ARN"
  value       = module.eks.karpenter_controller_role_arn
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = module.eks.kubeconfig_command
}

# ==========================================
# ECR Outputs
# ==========================================

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "javascript_api_ecr_url" {
  description = "JavaScript API ECR URL"
  value       = module.ecr.javascript_api_url
}

output "java_service_ecr_url" {
  description = "Java service ECR URL"
  value       = module.ecr.java_service_url
}

output "rust_processor_ecr_url" {
  description = "Rust processor ECR URL"
  value       = module.ecr.rust_processor_url
}