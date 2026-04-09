# ==========================================
# Dev Environment - Main Configuration
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

# ==========================================
# Local Variables
# ==========================================

locals {
  cluster_name = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# VPC Module
# ==========================================

module "vpc" {
  source = "../../modules/vpc"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  az_count     = var.az_count
  cluster_name = local.cluster_name
  
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  
  tags = local.common_tags
}

# ==========================================
# EKS Module
# ==========================================

module "eks" {
  source = "../../modules/eks"
  
  cluster_name = local.cluster_name
  environment  = var.environment
  region       = var.aws_region
  
  # Networking from VPC module
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  
  # Cluster configuration
  kubernetes_version      = var.kubernetes_version
  enable_public_endpoint  = var.enable_public_endpoint
  api_access_cidrs        = var.api_access_cidrs
  
  # Managed node group
  managed_node_group_desired_size    = var.managed_node_group_desired_size
  managed_node_group_min_size        = var.managed_node_group_min_size
  managed_node_group_max_size        = var.managed_node_group_max_size
  managed_node_group_instance_types  = var.managed_node_group_instance_types
  managed_node_group_capacity_type   = var.managed_node_group_capacity_type
  managed_node_group_disk_size       = var.managed_node_group_disk_size
  
  # EKS add-ons versions
  vpc_cni_version    = var.vpc_cni_version
  kube_proxy_version = var.kube_proxy_version
  coredns_version    = var.coredns_version
  
  # Karpenter
  enable_karpenter = var.enable_karpenter
  
  tags = local.common_tags
  
  depends_on = [module.vpc]
}

# ==========================================
# ECR Module
# ==========================================

module "ecr" {
  source = "../../modules/ecr"
  
  project_name = var.project_name
  environment  = var.environment
  
  service_names = var.service_names
  
  # Image lifecycle
  max_image_count          = var.ecr_max_image_count
  untagged_retention_days  = var.ecr_untagged_retention_days
  
  # Security
  scan_on_push = var.ecr_scan_on_push
  
  tags = local.common_tags
}
