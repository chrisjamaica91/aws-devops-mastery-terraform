# ==========================================
# Policy Outputs
# 
# Note: Individual policies have been split into separate files:
# - policy-infrastructure.tf (S3, EC2, VPC, AutoScaling)
# - policy-kubernetes.tf (EKS, ECR, IAM, KMS)
# - policy-supporting.tf (SQS, EventBridge, CloudWatch, Secrets)
# 
# This split was necessary due to AWS's 6KB policy size limit.
# Combined, these 3 policies provide least privilege access
# for GitHub Actions CI/CD operations.
# ==========================================

output "infrastructure_policy_arn" {
  description = "ARN of the infrastructure policy (S3, EC2, VPC, AutoScaling)"
  value       = aws_iam_policy.infrastructure.arn
}

output "kubernetes_policy_arn" {
  description = "ARN of the kubernetes policy (EKS, ECR, IAM, KMS)"
  value       = aws_iam_policy.kubernetes.arn
}

output "supporting_policy_arn" {
  description = "ARN of the supporting services policy (SQS, EventBridge, CloudWatch, Secrets)"
  value       = aws_iam_policy.supporting.arn
}

