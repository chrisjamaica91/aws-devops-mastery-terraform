# ==========================================
# Custom IAM Policy for GitHub Actions
# Principle: Least Privilege
# ==========================================

# Custom policy document with only required permissions
data "aws_iam_policy_document" "github_actions_permissions" {
  
  # ==========================================
  # S3 Permissions - Terraform State Management
  # ==========================================
  statement {
    sid    = "TerraformStateS3Access"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketVersioning",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketPolicy",
      "s3:PutEncryptionConfiguration",
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketTagging"
    ]
    resources = [
      "arn:aws:s3:::*-terraform-state-*",  # Only state buckets
    ]
  }

  statement {
    sid    = "TerraformStateObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::*-terraform-state-*/*",
    ]
  }

statement {
  sid    = "TerraformStateLockfileManagement"
  effect = "Allow"
  actions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject"
  ]
  resources = [
    "arn:aws:s3:::*-terraform-state-*/*.tflock"
  ]
}

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
  # EC2 - Networking & Compute
  # ==========================================
  statement {
    sid    = "EC2NetworkingAndCompute"
    effect = "Allow"
    actions = [
      # VPC operations
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcs",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:DescribeSubnets",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:DescribeRouteTables",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:DescribeInternetGateways",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",
      "ec2:DescribeNatGateways",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:DescribeAddresses",
      
      # Security Groups
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateSecurityGroupRule",
      "ec2:DeleteSecurityGroupRule",
      
      # Tags
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags",
      
      # Instances (for EKS worker nodes)
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeImages",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeAvailabilityZones",
      
      # Launch templates (for node groups)
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeLaunchTemplateVersions"
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
  # IAM - Limited Role Management
  # ==========================================
  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"
    actions = [
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
      "arn:aws:iam::*:role/eks-*",           # EKS service roles
      "arn:aws:iam::*:role/GitHubActions*",  # GitHub Actions roles
      "arn:aws:iam::*:role/*-node-role",     # EKS node roles
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

  # ==========================================
  # CloudWatch - Logging & Monitoring
  # ==========================================
  statement {
    sid    = "CloudWatchLogsAndMetrics"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }

  # ==========================================
  # AutoScaling - For EKS Node Groups
  # ==========================================
  statement {
    sid    = "AutoScalingManagement"
    effect = "Allow"
    actions = [
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:CreateOrUpdateTags"
    ]
    resources = ["*"]
  }

  # ==========================================
  # Secrets Manager - For Application Secrets
  # ==========================================
  statement {
    sid    = "SecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource"
    ]
    resources = [
      "arn:aws:secretsmanager:*:*:secret:eks/*",
      "arn:aws:secretsmanager:*:*:secret:app/*"
    ]
  }

  # ==========================================
  # Read-Only Access for Validation
  # ==========================================
  statement {
    sid    = "ReadOnlyAccess"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "account:GetAccountInformation",
      "pricing:GetProducts"
    ]
    resources = ["*"]
  }
}

# Create the custom policy
resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsDevOpsMasteryPolicy"
  description = "Least privilege policy for GitHub Actions CI/CD - DevOps Mastery Project"
  policy      = data.aws_iam_policy_document.github_actions_permissions.json

  tags = merge(
    var.tags,
    {
      Name      = "GitHubActionsDevOpsMasteryPolicy"
      ManagedBy = "Terraform"
      Purpose   = "Least Privilege CI/CD Access"
    }
  )
}

# Output the policy ARN
output "custom_policy_arn" {
  description = "ARN of the custom least privilege policy"
  value       = aws_iam_policy.github_actions_policy.arn
}
