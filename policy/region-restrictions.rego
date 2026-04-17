package terraform.region_restrictions

# Policy: All AWS resources must be in allowed regions
deny[msg] {
  resource := input.resource_changes[_]
  is_regional_resource(resource.type)
  resource_region := get_resource_region(resource)
  resource_region != null
  not allowed_region(resource_region)
  
  msg := sprintf(
    "🌎 REGION: Resource '%s' is in region '%s'. Only us-east-1 is allowed for data residency compliance.",
    [resource.address, resource_region]
  )
}

# Policy: Provider configuration must use allowed region
deny[msg] {
  provider := input.configuration.provider_config.aws
  provider_region := provider.expressions.region.constant_value
  provider_region != null
  not allowed_region(provider_region)
  
  msg := sprintf(
    "🌎 REGION: AWS provider configured for region '%s'. Only us-east-1 is allowed.",
    [provider_region]
  )
}

# Policy: S3 backend must use allowed region
deny[msg] {
  backend := input.configuration.terraform.backend.s3
  backend_region := backend.region
  backend_region != null
  not allowed_region(backend_region)
  
  msg := sprintf(
    "🌎 REGION: Terraform backend configured for region '%s'. Only us-east-1 is allowed.",
    [backend_region]
  )
}

# Helper: Check if resource type is regional (not global)
is_regional_resource(resource_type) {
  not global_resources[resource_type]
}

# Helper: Global resources (not region-specific)
global_resources := {
  "aws_iam_role",
  "aws_iam_policy",
  "aws_iam_role_policy_attachment",
  "aws_iam_openid_connect_provider",
  "aws_route53_zone",
  "aws_route53_record"
}

# Helper: Get region from resource
get_resource_region(resource) := region {
  region := resource.change.after.region
}

# Helper: Get region from resource availability_zone
get_resource_region(resource) := region {
  az := resource.change.after.availability_zone
  region := regex.find_n("^[a-z]{2}-[a-z]+-[0-9]+", az, 1)[0]
}

# Helper: Check if region is allowed
allowed_region(region) {
  allowed_regions := {"us-east-1", "us-east-2"}
  allowed_regions[region]
}