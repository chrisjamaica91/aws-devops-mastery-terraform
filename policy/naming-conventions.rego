package terraform.naming_conventions

# Policy: S3 buckets must follow naming convention
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  bucket_name := resource.change.after.bucket
  not regex.match("^aws-devops-mastery-[a-z0-9-]+$", bucket_name)
  
  msg := sprintf(
    "📛 NAMING: S3 bucket '%s' does not follow naming convention. Expected: aws-devops-mastery-{purpose}-{environment}",
    [bucket_name]
  )
}

# Policy: EKS clusters must include environment in name
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_eks_cluster"
  cluster_name := resource.change.after.name
  not contains(cluster_name, "-dev")
  not contains(cluster_name, "-staging")
  not contains(cluster_name, "-production")
  
  msg := sprintf(
    "📛 NAMING: EKS cluster '%s' must include environment suffix (-dev, -staging, or -production)",
    [cluster_name]
  )
}

# Policy: IAM roles must follow prefix convention
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_iam_role"
  role_name := resource.change.after.name
  not starts_with_project_prefix(role_name)
  
  msg := sprintf(
    "📛 NAMING: IAM role '%s' must start with project prefix (GitHubActions, eks-, karpenter-)",
    [role_name]
  )
}

# Policy: Security groups must have descriptive names (no 'sg-' prefix only)
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group"
  sg_name := resource.change.after.name
  regex.match("^sg-[0-9]+$", sg_name)
  
  msg := sprintf(
    "📛 NAMING: Security group '%s' uses auto-generated name. Provide descriptive name: {project}-{environment}-{purpose}-sg",
    [sg_name]
  )
}

# Policy: VPCs must include environment in name
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_vpc"
  vpc_name := get_name_tag(resource)
  vpc_name != null
  not contains(vpc_name, "dev")
  not contains(vpc_name, "staging")
  not contains(vpc_name, "production")
  
  msg := sprintf(
    "📛 NAMING: VPC name '%s' must include environment (dev, staging, or production)",
    [vpc_name]
  )
}

# Helper: Check if role name starts with allowed prefix
starts_with_project_prefix(name) {
  allowed_prefixes := {"GitHubActions", "eks-", "karpenter-", "aws-devops-mastery"}
  startswith(name, allowed_prefixes[_])
}

# Helper: Get Name tag from resource
get_name_tag(resource) := name {
  tags := object.get(resource.change.after, "tags", {})
  name := tags.Name
}