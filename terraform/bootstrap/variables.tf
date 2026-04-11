# ==========================================
# Variables
# ==========================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_repositories" {
  description = "List of GitHub repositories in format: owner/repo"
  type        = list(string)
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-devops-mastery"
}