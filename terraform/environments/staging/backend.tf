# ==========================================
# Backend Configuration - Staging Environment
# ==========================================
# State stored in: aws-devops-mastery-terraform-state-staging

terraform {
  backend "s3" {
    bucket       = "aws-devops-mastery-terraform-state-staging"
    key          = "infrastructure/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

  }
}
