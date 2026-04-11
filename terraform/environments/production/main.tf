# ==========================================
# Production Environment - Main Configuration
# ==========================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "AWS-DevOps-Mastery"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# Future infrastructure will go here
