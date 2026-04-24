# ==========================================
# Staging Environment Configuration
# ==========================================

# General
environment  = "staging"
aws_region   = "us-east-2"
project_name = "aws-devops-mastery"

# VPC - Production-like setup
vpc_cidr           = "10.1.0.0/16" # Different from dev (10.0.0.0/16)
az_count           = 2
enable_nat_gateway = true
single_nat_gateway = false # NAT per AZ for HA (more production-like)

# EKS - Medium cluster for staging
kubernetes_version     = "1.30"
enable_public_endpoint = true          # Access for testing
api_access_cidrs       = ["0.0.0.0/0"] # Restrict in production

# Managed Node Group - Production-like sizing
managed_node_group_desired_size   = 2
managed_node_group_min_size       = 2
managed_node_group_max_size       = 5
managed_node_group_instance_types = ["t3.large"] # Larger than dev
managed_node_group_capacity_type  = "ON_DEMAND"  # No SPOT for stability
managed_node_group_disk_size      = 30

# EKS Add-ons (compatible with k8s 1.30)
vpc_cni_version    = "v1.18.1-eksbuild.1"
kube_proxy_version = "v1.30.0-eksbuild.3"
coredns_version    = "v1.11.1-eksbuild.8"

# Karpenter
enable_karpenter = true

# ECR - Moderate retention for staging
service_names               = ["javascript-api", "java-service", "rust-processor"]
ecr_max_image_count         = 15 # Keep more images than dev
ecr_untagged_retention_days = 14 # 2 weeks vs 7 days in dev
ecr_scan_on_push            = true
