# ==========================================
# Dev Environment Configuration
# ==========================================

# General
environment  = "dev"
aws_region   = "us-east-2"
project_name = "aws-devops-mastery"

# VPC - Cost-optimized for dev
vpc_cidr           = "10.0.0.0/16"
az_count           = 2
enable_nat_gateway = true
single_nat_gateway = true  # Single NAT = $32/month vs $64/month

# EKS - Small cluster for dev
kubernetes_version     = "1.30"
enable_public_endpoint = true  # Access from home/office
api_access_cidrs       = ["0.0.0.0/0"]  # Restrict in production

# Managed Node Group - 2 small nodes
managed_node_group_desired_size   = 2
managed_node_group_min_size       = 1
managed_node_group_max_size       = 3
managed_node_group_instance_types = ["t3.medium"]
managed_node_group_capacity_type  = "ON_DEMAND"  # Use SPOT for further savings
managed_node_group_disk_size      = 20

# EKS Add-ons (compatible with k8s 1.30)
vpc_cni_version    = "v1.18.1-eksbuild.1"
kube_proxy_version = "v1.30.0-eksbuild.3"
coredns_version    = "v1.11.1-eksbuild.8"

# Karpenter
enable_karpenter = true

# ECR - Aggressive cleanup for dev
service_names               = ["javascript-api", "java-service", "rust-processor"]
ecr_max_image_count         = 5  # Keep only 5 recent images
ecr_untagged_retention_days = 7
ecr_scan_on_push            = true