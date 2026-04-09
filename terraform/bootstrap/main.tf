# ==========================================
# Bootstrap: Foundation Infrastructure
# ==========================================
# This creates:
# 1. OIDC provider for GitHub Actions authentication
# 2. S3 + DynamoDB for Terraform remote state (dev, staging, production)
#
# This uses LOCAL state (chicken and egg problem)
# Everything else will use REMOTE state stored in the S3 buckets created here

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Using LOCAL state for bootstrap
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "AWS-DevOps-Mastery"
      ManagedBy   = "Terraform"
      Environment = "bootstrap"
    }
  }
}

# ==========================================
# Module 1: GitHub OIDC Authentication
# ==========================================

module "github_oidc" {
  source = "../modules/github-oidc"
  
  github_repository = var.github_repository
  role_name         = "GitHubActionsRole-DevOpsMastery"
}

# ==========================================
# Module 2: Terraform State Infrastructure
# ==========================================

# Dev environment state
module "terraform_state_dev" {
  source = "../modules/terraform-state"
  
  environment        = "dev"
  project_name       = var.project_name
  enable_versioning  = true
  enable_replication = false
}

# Staging environment state
module "terraform_state_staging" {
  source = "../modules/terraform-state"
  
  environment        = "staging"
  project_name       = var.project_name
  enable_versioning  = true
  enable_replication = false
}

# Production environment state
module "terraform_state_production" {
  source = "../modules/terraform-state"
  
  environment        = "production"
  project_name       = var.project_name
  enable_versioning  = true
  enable_replication = false  # Set to true for cross-region replication
}