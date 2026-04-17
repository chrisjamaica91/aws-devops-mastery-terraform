package terraform.security_baseline

# Policy: All S3 buckets must have encryption enabled
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not has_encryption_configuration(resource)
  
  msg := sprintf(
    "🔒 SECURITY: S3 bucket '%s' missing encryption configuration. All buckets must use AES256 or KMS encryption.",
    [resource.address]
  )
}

# Policy: S3 buckets must block public access
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_public_access_block"
  not all_public_access_blocked(resource)
  
  msg := sprintf(
    "🔒 SECURITY: S3 bucket '%s' allows public access. All buckets must block public access unless explicitly approved.",
    [resource.address]
  )
}

# Policy: EKS clusters must have encryption enabled for secrets
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_eks_cluster"
  not has_secrets_encryption(resource)
  
  msg := sprintf(
    "🔒 SECURITY: EKS cluster '%s' missing KMS encryption for Kubernetes secrets. Encryption required for compliance.",
    [resource.address]
  )
}

# Policy: EKS clusters must have control plane logging enabled
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_eks_cluster"
  not has_control_plane_logging(resource)
  
  msg := sprintf(
    "🔒 SECURITY: EKS cluster '%s' missing control plane logging. Enable api, audit, authenticator logs for security monitoring.",
    [resource.address]
  )
}

# Policy: RDS instances must have encryption enabled
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_db_instance"
  not resource.change.after.storage_encrypted
  
  msg := sprintf(
    "🔒 SECURITY: RDS instance '%s' missing storage encryption. All databases must be encrypted at rest.",
    [resource.address]
  )
}

# Policy: Security groups must not allow 0.0.0.0/0 ingress on sensitive ports
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group"
  rule := resource.change.after.ingress[_]
  rule.cidr_blocks[_] == "0.0.0.0/0"
  sensitive_port(rule.from_port)
  
  msg := sprintf(
    "🔒 SECURITY: Security group '%s' allows 0.0.0.0/0 ingress on port %d. Restrict to specific IP ranges.",
    [resource.address, rule.from_port]
  )
}

# Policy: IAM policies must not have wildcard actions on all resources
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_iam_policy"
  statement := json.unmarshal(resource.change.after.policy).Statement[_]
  statement.Effect == "Allow"
  statement.Action == "*"
  statement.Resource == "*"
  
  msg := sprintf(
    "🔒 SECURITY: IAM policy '%s' grants wildcard (*) actions on all resources (*). Use least-privilege permissions.",
    [resource.address]
  )
}

# Helper: Check if S3 bucket has encryption
has_encryption_configuration(resource) {
  resource.change.after.server_side_encryption_configuration
}

# Helper: Check if all S3 public access is blocked
all_public_access_blocked(resource) {
  resource.change.after.block_public_acls == true
  resource.change.after.block_public_policy == true
  resource.change.after.ignore_public_acls == true
  resource.change.after.restrict_public_buckets == true
}

# Helper: Check if EKS has secrets encryption
has_secrets_encryption(resource) {
  resource.change.after.encryption_config[_].resources[_] == "secrets"
}

# Helper: Check if EKS has control plane logging
has_control_plane_logging(resource) {
  enabled_log_types := resource.change.after.enabled_cluster_log_types
  count(enabled_log_types) > 0
}

# Helper: Sensitive ports that should not be open to the world
sensitive_port(port) {
  sensitive_ports := {22, 3389, 3306, 5432, 1433, 6379, 27017, 9200, 5601}
  sensitive_ports[port]
}