# ==========================================
# Data Sources
# ==========================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# IAM Role: What the EKS cluster can do
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  # Trust policy: WHO can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"  # Only EKS service
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach AWS-managed policy (contains all necessary permissions)
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Optional: VPC Resource Controller (for security group management)
resource "aws_iam_role_policy_attachment" "cluster_vpc_resource_controller" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key for ${var.cluster_name}"
  deletion_window_in_days = 30  # Can't delete immediately (safety)
  enable_key_rotation     = true  # Automatic annual rotation

  tags = {
    Name = "${var.cluster_name}-eks-encryption-key"
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/eks/${var.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.environment == "dev" ? 7 : 30  # Cost optimization

  tags = {
    Name = "${var.cluster_name}-eks-logs"
  }
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.kubernetes_version  # e.g., "1.28"
  role_arn = aws_iam_role.cluster.arn

  # VPC Configuration
  vpc_config {
    subnet_ids = var.private_subnet_ids  # Private subnets from VPC module
    
    # API endpoint access
    endpoint_private_access = true  # Nodes can reach API
    endpoint_public_access  = var.enable_public_endpoint  # Dev: true, Prod: false
    
    # Production: Restrict public access to specific IPs
    public_access_cidrs = var.enable_public_endpoint ? var.api_access_cidrs : []
    
    # Security groups (EKS creates one automatically)
    # You can add extra security groups here if needed
  }

  # Secrets Encryption (CRITICAL for production)
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]  # Encrypt Kubernetes secrets
  }

  # Control Plane Logging
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Dependencies (create in order)
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_cloudwatch_log_group.eks
  ]

  tags = {
    Name = var.cluster_name
  }
}

# Tag the cluster security group for Karpenter discovery
resource "aws_ec2_tag" "cluster_security_group_karpenter" {
  resource_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"  # EC2 instances assume this
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ==========================================
# VPC CNI IRSA Role (for pod networking)
# ==========================================

resource "aws_iam_role" "vpc_cni" {
  name = "${var.cluster_name}-vpc-cni-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.cluster.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-node"
          "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
  
  depends_on = [aws_iam_openid_connect_provider.cluster]
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Required policies (AWS-managed)
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optional: SSM access for debugging (connect without SSH)
resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "managed" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-managed-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  
  # Scaling configuration (base capacity)
  scaling_config {
    desired_size = var.managed_node_group_desired_size  # Dev: 2, Prod: 3
    min_size     = var.managed_node_group_min_size      # Dev: 1, Prod: 2
    max_size     = var.managed_node_group_max_size      # Dev: 3, Prod: 5
  }
  
  # Update strategy (rolling updates)
  update_config {
    max_unavailable = 1  # Update one node at a time
  }
  
  # Instance configuration
  ami_type       = "AL2_x86_64"  # Amazon Linux 2 EKS-optimized
  capacity_type  = var.managed_node_group_capacity_type  # "ON_DEMAND" or "SPOT"
  instance_types = var.managed_node_group_instance_types  # e.g., ["t3.medium"]
  disk_size      = var.managed_node_group_disk_size       # Default: 20GB
  
  # Labels (for pod scheduling)
  labels = {
    role = "managed"
    lifecycle = var.managed_node_group_capacity_type == "SPOT" ? "spot" : "on-demand"
  }
  
  # Taints (optional - prevent user pods from scheduling here)
  # Useful if you want this node group ONLY for system pods
  dynamic "taint" {
    for_each = var.managed_node_group_taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  
  # Remote access (optional - for debugging)
  # remote_access {
  #   ec2_ssh_key = var.ssh_key_name
  #   source_security_group_ids = [var.bastion_security_group_id]
  # }
  
  # Ensure node group is created after cluster and policies
  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]
  
  tags = {
    Name                                        = "${var.cluster_name}-managed-node"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"          = "true"
  }
}

# 1. VPC CNI - Pod networking
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
  addon_version = var.vpc_cni_version  # e.g., "v1.15.1-eksbuild.1"
  
  # Resolve conflicts by overwriting
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  
  # Service account for IRSA (IAM Roles for Service Accounts)
  service_account_role_arn = aws_iam_role.vpc_cni.arn
  
  depends_on = [aws_eks_node_group.managed]
}

# 2. kube-proxy - Network proxy on each node
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
  addon_version = var.kube_proxy_version
  
  depends_on = [aws_eks_node_group.managed]
}

# 3. CoreDNS - DNS server for cluster
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
  addon_version = var.coredns_version
  
  # CoreDNS runs as pods, needs nodes to exist first
  depends_on = [aws_eks_node_group.managed]
}