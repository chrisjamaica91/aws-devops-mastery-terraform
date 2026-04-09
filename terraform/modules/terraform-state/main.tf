# ==========================================
# Terraform State Management Module
# ==========================================
# Creates S3 bucket and DynamoDB table for remote state storage

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ==========================================
# S3 Bucket for Terraform State
# ==========================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-${var.environment}"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State - ${title(var.environment)}"
    Environment = var.environment
    Purpose     = "Terraform Remote State Storage"
  }
}

# Enable versioning - allows state rollback
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Encrypt state files at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access (state files contain secrets!)
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy - manage old versions
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    # Apply to all objects
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.environment == "production" ? 90 : 30
    }
  }

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    # Apply to all objects
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ==========================================
# DynamoDB Table for State Locking
# ==========================================

resource "aws_dynamodb_table" "terraform_lock" {
  count = var.enable_dynamodb_locking ? 1 : 0 
  name         = "terraform-lock-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"  # Cost: ~$0.01/month with light usage
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Enable point-in-time recovery for production
  point_in_time_recovery {
    enabled = var.environment == "production"
  }

  tags = {
    Name        = "Terraform Lock - ${title(var.environment)}"
    Environment = var.environment
    Purpose     = "Terraform State Locking"
  }
}

# Get current region
data "aws_region" "current" {}
