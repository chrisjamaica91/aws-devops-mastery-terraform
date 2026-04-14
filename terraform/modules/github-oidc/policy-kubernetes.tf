# ==========================================
# Kubernetes Policy - EKS & Container Services
# Covers: EKS, ECR, IAM (for K8s roles), KMS
# ==========================================

data "aws_iam_policy_document" "kubernetes" {

  # ==========================================
  # EKS - Kubernetes Cluster Management
  # ==========================================
  statement {
    sid    = "EKSClusterManagement"
    effect = "Allow"
    actions = [
      "eks:CreateCluster",
      "eks:DeleteCluster",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:CreateNodegroup",
      "eks:DeleteNodegroup",
      "eks:DescribeNodegroup",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
      "eks:CreateAddon",
      "eks:DeleteAddon",
      "eks:DescribeAddon",
      "eks:UpdateAddon"
    ]
    resources = ["*"]
  }

  # ==========================================
  # ECR - Container Registry
  # ==========================================
  statement {
    sid    = "ECRRepositoryManagement"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:ListTagsForResource",
      "ecr:UntagResource",
      "ecr:PutImageTagImmutability",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutLifecyclePolicy",
      "ecr:SetRepositoryPolicy",
      "ecr:TagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRImageOperations"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }

  # ==========================================
  # KMS - Encryption Key Management
  # ==========================================
  statement {
    sid    = "KMSKeyManagement"
    effect = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListResourceTags",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:EnableKeyRotation",
    ]
    resources = ["arn:aws:kms:*:*:key/*"]
  }

  # ==========================================
  # IAM - Limited Role Management for K8s
  # ==========================================
  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:UpdateRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/eks-*",          # EKS service roles
      "arn:aws:iam::*:role/GitHubActions*", # GitHub Actions roles
      "arn:aws:iam::*:role/*-node-role",    # EKS node roles
      "arn:aws:iam::*:role/*-karpenter-*",  # Karpenter roles
      "arn:aws:iam::*:role/*-cluster-role", # Cluster roles
    ]
  }

  statement {
    sid    = "IAMInstanceProfileManagement"
    effect = "Allow"
    actions = [
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:ListInstanceProfiles",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile"
    ]
    resources = [
      "arn:aws:iam::*:instance-profile/eks-*",
    ]
  }

  statement {
    sid    = "IAMPolicyManagement"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion"
    ]
    resources = [
      "arn:aws:iam::*:policy/eks-*",
      "arn:aws:iam::*:policy/GitHubActions*"
    ]
  }
}

# Create the kubernetes policy
resource "aws_iam_policy" "kubernetes" {
  name        = "GitHubActionsDevOpsMastery-Kubernetes"
  description = "Kubernetes permissions for GitHub Actions - EKS, ECR, IAM, KMS"
  policy      = data.aws_iam_policy_document.kubernetes.json

  tags = merge(
    var.tags,
    {
      Name      = "GitHubActionsDevOpsMastery-Kubernetes"
      ManagedBy = "Terraform"
      Purpose   = "Least Privilege CI/CD - Kubernetes"
    }
  )
}
