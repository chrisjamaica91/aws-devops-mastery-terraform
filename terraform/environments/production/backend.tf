# ==========================================
# Backend Configuration - Production Environment
# ==========================================
# State stored in: aws-devops-mastery-terraform-state-production

terraform {
  backend "s3" {
    bucket         = "aws-devops-mastery-terraform-state-production"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile = true

  }
}
