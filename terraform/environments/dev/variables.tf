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
  default     = "dev"
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
  default     = "10.0.0.0/16"
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
  default     = true
}

# ==========================================
# EKS Configuration
# ==========================================

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
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
  default     = 1
}

variable "managed_node_group_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "managed_node_group_instance_types" {
  description = "Instance types for managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "managed_node_group_capacity_type" {
  description = "Capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "managed_node_group_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

# ==========================================
# EKS Add-ons
# ==========================================

variable "vpc_cni_version" {
  description = "VPC CNI add-on version"
  type        = string
  default     = "v1.15.1-eksbuild.1"
}

variable "kube_proxy_version" {
  description = "kube-proxy add-on version"
  type        = string
  default     = "v1.28.2-eksbuild.2"
}

variable "coredns_version" {
  description = "CoreDNS add-on version"
  type        = string
  default     = "v1.10.1-eksbuild.6"
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
  description = "Maximum number of images to retain"
  type        = number
  default     = 5
}

variable "ecr_untagged_retention_days" {
  description = "Days to retain untagged images"
  type        = number
  default     = 7
}

variable "ecr_scan_on_push" {
  description = "Enable vulnerability scanning on image push"
  type        = bool
  default     = true
}