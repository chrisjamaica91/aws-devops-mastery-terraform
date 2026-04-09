# ==========================================
# ECR Module - Container Image Registry
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

# ==========================================
# ECR Repositories (one per service)
# ==========================================

resource "aws_ecr_repository" "service" {
  for_each = toset(var.service_names)
  
  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = var.image_tag_mutability
  
  # Encryption at rest
  encryption_configuration {
    encryption_type = var.encryption_type
    # Optional: Use KMS for customer-managed encryption
    kms_key = var.kms_key_arn
  }
  
  # Vulnerability scanning
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  
  tags = merge(
    var.tags,
    {
      Name        = each.value
      Environment = var.environment
      Service     = each.value
    }
  )
}

# ==========================================
# Lifecycle Policies (auto-delete old images)
# ==========================================

resource "aws_ecr_lifecycle_policy" "service" {
  for_each = aws_ecr_repository.service
  
  repository = each.value.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than ${var.untagged_retention_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_retention_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ==========================================
# Repository Policies (optional - cross-account access)
# ==========================================

resource "aws_ecr_repository_policy" "service" {
  for_each = var.enable_cross_account_access ? aws_ecr_repository.service : {}
  
  repository = each.value.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromOtherAccounts"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_account_ids
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}