# ==========================================
# GitHub OIDC Provider for AWS
# ==========================================
# This allows GitHub Actions to authenticate to AWS without access keys
# Uses OpenID Connect (OIDC) for temporary, secure credentials

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create OIDC provider - tells AWS to trust GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  # Audience: prevents token re-use in other contexts
  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Thumbprint: GitHub's TLS certificate fingerprint
  # This verifies we're really talking to GitHub
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd" # Backup thumbprint
  ]

  tags = {
    Name      = "GitHub Actions OIDC Provider"
    ManagedBy = "Terraform"
    Purpose   = "CI/CD Authentication"
  }
}

# Output the OIDC provider ARN (we'll need this for IAM roles)
output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "oidc_provider_url" {
  description = "URL of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.url
}
