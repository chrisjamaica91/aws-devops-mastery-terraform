
# Input variables
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "project_name" {
  description = "Project name used in bucket naming"
  type        = string
  default     = "aws-devops-mastery"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning (recommended for production)"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Enable cross-region replication (production only)"
  type        = bool
  default     = false
}
variable "enable_dynamodb_locking" {
  description = "Enable DynamoDB state locking (deprecated - use S3 native locking instead)"
  type        = bool
  default     = false
}