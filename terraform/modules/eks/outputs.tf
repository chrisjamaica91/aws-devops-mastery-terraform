# ==========================================
# EKS Module Outputs
# ==========================================

# ==========================================
# Cluster Information
# ==========================================

output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "EKS platform version"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_status" {
  description = "EKS cluster status"
  value       = aws_eks_cluster.main.status
}

# ==========================================
# Cluster Security
# ==========================================

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster authentication"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# ==========================================
# OIDC Provider (for IRSA)
# ==========================================

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = aws_iam_openid_connect_provider.cluster.url
}

output "oidc_provider_issuer" {
  description = "Issuer URL for OIDC provider (without https://)"
  value       = replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")
}

# ==========================================
# IAM Roles
# ==========================================

output "cluster_iam_role_arn" {
  description = "IAM role ARN for EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN for EKS managed nodes"
  value       = aws_iam_role.node.arn
}

output "node_iam_role_name" {
  description = "IAM role name for EKS managed nodes"
  value       = aws_iam_role.node.name
}

# ==========================================
# Karpenter Resources
# ==========================================

output "karpenter_controller_role_arn" {
  description = "IAM role ARN for Karpenter controller"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  description = "IAM role ARN for Karpenter-provisioned nodes"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_instance_profile_name" {
  description = "Instance profile name for Karpenter nodes"
  value       = aws_iam_instance_profile.karpenter_node.name
}

output "karpenter_interruption_queue_name" {
  description = "SQS queue name for Karpenter interruption handling"
  value       = var.enable_karpenter ? aws_sqs_queue.karpenter_interruption[0].name : null
}

# ==========================================
# Node Group
# ==========================================

output "managed_node_group_id" {
  description = "Managed node group ID"
  value       = aws_eks_node_group.managed.id
}

output "managed_node_group_arn" {
  description = "Managed node group ARN"
  value       = aws_eks_node_group.managed.arn
}

output "managed_node_group_status" {
  description = "Managed node group status"
  value       = aws_eks_node_group.managed.status
}

# ==========================================
# Useful for kubectl Configuration
# ==========================================

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${aws_eks_cluster.main.name}"
}