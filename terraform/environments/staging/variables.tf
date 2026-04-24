# ==========================================
# General Configuration
# ==========================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-devops-mastery"
}

# ==========================================
# VPC Configuration
# ==========================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway (cost savings) vs one per AZ"
  type        = bool
  default     = false
}

# ==========================================
# EKS Configuration
# ==========================================

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "enable_public_endpoint" {
  description = "Enable public EKS API endpoint"
  type        = bool
  default     = true
}

variable "api_access_cidrs" {
  description = "CIDR blocks allowed to access EKS API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ==========================================
# Managed Node Group Configuration
# ==========================================

variable "managed_node_group_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "managed_node_group_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "managed_node_group_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "managed_node_group_instance_types" {
  description = "Instance types for managed node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "managed_node_group_capacity_type" {
  description = "Capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "managed_node_group_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 30
}

# ==========================================
# EKS Add-ons
# ==========================================

variable "vpc_cni_version" {
  description = "VPC CNI add-on version"
  type        = string
  default     = "v1.18.1-eksbuild.1"
}

variable "kube_proxy_version" {
  description = "kube-proxy add-on version"
  type        = string
  default     = "v1.30.0-eksbuild.3"
}

variable "coredns_version" {
  description = "CoreDNS add-on version"
  type        = string
  default     = "v1.11.1-eksbuild.8"
}

# ==========================================
# Karpenter
# ==========================================

variable "enable_karpenter" {
  description = "Enable Karpenter autoscaler"
  type        = bool
  default     = true
}

# ==========================================
# ECR Configuration
# ==========================================

variable "service_names" {
  description = "List of service names for ECR repositories"
  type        = list(string)
  default     = ["javascript-api", "java-service", "rust-processor"]
}

variable "ecr_max_image_count" {
  description = "Maximum number of images to keep per repository"
  type        = number
  default     = 15
}

variable "ecr_untagged_retention_days" {
  description = "Days to retain untagged images"
  type        = number
  default     = 14
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}
