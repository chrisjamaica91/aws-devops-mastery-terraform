# ==========================================
# IAM Roles for GitHub Actions
# ==========================================
# These roles define what GitHub Actions can do in AWS

# Variable for GitHub repositories allowed to assume the role
variable "github_repositories" {
  description = "List of GitHub repositories in format: owner/repo"
  type        = list(string)
}

variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
  default     = "GitHubActionsRole"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = var.role_name

  # Trust policy: Who can assume this role?
  # Answer: GitHub Actions from our specific repository
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # Verify the token is for AWS STS
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Allow multiple repositories (all branches)
            "token.actions.githubusercontent.com:sub" = [
              for repo in var.github_repositories : "repo:${repo}:*"
            ]
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = var.role_name
      ManagedBy = "Terraform"
      Purpose   = "GitHub Actions CI/CD"
    }
  )
}

# Attach all 3 custom least privilege policies
resource "aws_iam_role_policy_attachment" "infrastructure" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.infrastructure.arn
}

resource "aws_iam_role_policy_attachment" "kubernetes" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.kubernetes.arn
}

resource "aws_iam_role_policy_attachment" "supporting" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.supporting.arn
}

# Output the role ARN (we'll use this in GitHub Actions)
output "role_arn" {
  description = "ARN of the GitHub Actions IAM role - use this in workflows"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions.name
}
