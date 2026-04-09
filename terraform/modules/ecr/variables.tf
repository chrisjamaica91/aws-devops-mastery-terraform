# ==========================================
# ECR Module Variables
# ==========================================

variable "project_name" {
  description = "Project name for repository naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "service_names" {
  description = "List of service names (creates one repo per service)"
  type        = list(string)
  
  validation {
    condition     = length(var.service_names) > 0
    error_message = "At least one service name is required."
  }
}

variable "image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Must be MUTABLE or IMMUTABLE."
  }
}

variable "encryption_type" {
  description = "Encryption type (AES256 or KMS)"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Must be AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (if encryption_type = KMS)"
  type        = string
  default     = null
}

variable "scan_on_push" {
  description = "Enable vulnerability scanning on image push"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to retain per repository"
  type        = number
  default     = 10
}

variable "untagged_retention_days" {
  description = "Days to retain untagged images before deletion"
  type        = number
  default     = 7
}

variable "enable_cross_account_access" {
  description = "Enable cross-account ECR access"
  type        = bool
  default     = false
}

variable "allowed_account_ids" {
  description = "AWS account IDs allowed to pull images (for cross-account access)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for repositories"
  type        = map(string)
  default     = {}
}