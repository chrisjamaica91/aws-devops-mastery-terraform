# ==========================================
# Infrastructure Policy - Core AWS Services
# Covers: S3, EC2, VPC, AutoScaling
# ==========================================

data "aws_iam_policy_document" "infrastructure" {

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
      "arn:aws:s3:::*-terraform-state-*", # Only state buckets
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
      "ec2:DescribeVpcAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:Describe*",
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

# Create the infrastructure policy
resource "aws_iam_policy" "infrastructure" {
  name        = "GitHubActionsDevOpsMastery-Infrastructure"
  description = "Infrastructure permissions for GitHub Actions - S3, EC2, VPC, AutoScaling"
  policy      = data.aws_iam_policy_document.infrastructure.json

  tags = merge(
    var.tags,
    {
      Name      = "GitHubActionsDevOpsMastery-Infrastructure"
      ManagedBy = "Terraform"
      Purpose   = "Least Privilege CI/CD - Infrastructure"
    }
  )
}
