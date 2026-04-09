# ==========================================
# Variables
# ==========================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository in format: owner/repo"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-devops-mastery"
}