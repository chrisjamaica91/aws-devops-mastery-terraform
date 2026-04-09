# ==========================================
# EKS Module Variables
# ==========================================

# ==========================================
# General Configuration
# ==========================================

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  
  validation {
    condition     = length(var.cluster_name) <= 40
    error_message = "Cluster name must be 40 characters or less."
  }
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
}

# ==========================================
# Networking
# ==========================================

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
  
  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets required for EKS high availability."
  }
}

# ==========================================
# EKS Cluster Configuration
# ==========================================

variable "kubernetes_version" {
  description = "Kubernetes version (e.g., 1.28, 1.29)"
  type        = string
  default     = "1.28"
}

variable "enable_public_endpoint" {
  description = "Enable public API endpoint (true for dev, false for production)"
  type        = bool
  default     = true
}

variable "api_access_cidrs" {
  description = "CIDR blocks allowed to access public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Dev: open, Prod: restrict to office/VPN
}

# ==========================================
# Managed Node Group Configuration
# ==========================================

variable "managed_node_group_desired_size" {
  description = "Desired number of nodes in managed node group"
  type        = number
  default     = 2
}

variable "managed_node_group_min_size" {
  description = "Minimum number of nodes in managed node group"
  type        = number
  default     = 1
}

variable "managed_node_group_max_size" {
  description = "Maximum number of nodes in managed node group"
  type        = number
  default     = 5
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
  
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.managed_node_group_capacity_type)
    error_message = "Capacity type must be ON_DEMAND or SPOT."
  }
}

variable "managed_node_group_disk_size" {
  description = "Disk size in GB for managed node group"
  type        = number
  default     = 20
}

variable "managed_node_group_taints" {
  description = "Taints for managed node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

# ==========================================
# EKS Add-ons Versions
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
# Karpenter Configuration
# ==========================================

variable "enable_karpenter" {
  description = "Enable Karpenter autoscaler"
  type        = bool
  default     = true
}

# ==========================================
# Tags
# ==========================================

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}