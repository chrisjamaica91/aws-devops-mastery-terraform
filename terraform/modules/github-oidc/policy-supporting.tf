# ==========================================
# Supporting Services Policy
# Covers: SQS, EventBridge, CloudWatch, Secrets Manager
# ==========================================

data "aws_iam_policy_document" "supporting" {

  # ==========================================
  # SQS - Queue Management for Karpenter
  # ==========================================
  statement {
    sid    = "SQSQueueManagement"
    effect = "Allow"
    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:UntagQueue",
      "sqs:ListQueueTags",
    ]
    resources = ["arn:aws:sqs:*:*:*-karpenter-*"]
  }

  # ==========================================
  # EventBridge - Event Rules for Karpenter
  # ==========================================
  statement {
    sid    = "EventBridgeManagement"
    effect = "Allow"
    actions = [
      "events:PutRule",
      "events:DeleteRule",
      "events:DescribeRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "events:TagResource",
      "events:UntagResource",
      "events:ListTagsForResource",
    ]
    resources = ["arn:aws:events:*:*:rule/*-karpenter-*"]
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
      "logs:ListTagsForResource",
      "logs:UntagLogGroup",
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics"
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
}

# Create the supporting services policy
resource "aws_iam_policy" "supporting" {
  name        = "GitHubActionsDevOpsMastery-Supporting"
  description = "Supporting services permissions for GitHub Actions - SQS, EventBridge, CloudWatch, Secrets"
  policy      = data.aws_iam_policy_document.supporting.json

  tags = merge(
    var.tags,
    {
      Name      = "GitHubActionsDevOpsMastery-Supporting"
      ManagedBy = "Terraform"
      Purpose   = "Least Privilege CI/CD - Supporting Services"
    }
  )
}
