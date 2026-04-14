# ==========================================
# Backend Configuration - Dev Environment
# ==========================================
# State stored in: aws-devops-mastery-terraform-state-dev

terraform {
  backend "s3" {
    bucket       = "aws-devops-mastery-terraform-state-dev"
    key          = "infrastructure/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

  }
}
