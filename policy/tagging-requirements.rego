package terraform.tagging_requirements

# Policy: All taggable resources must have required tags
deny[msg] {
  resource := input.resource_changes[_]
  is_taggable_resource(resource.type)
  missing_tags := get_missing_required_tags(resource)
  count(missing_tags) > 0
  
  msg := sprintf(
    "🏷️ TAGGING: Resource '%s' missing required tags: %s. Required: Environment, Project, ManagedBy",
    [resource.address, concat(", ", missing_tags)]
  )
}

# Policy: Environment tag must be valid value
deny[msg] {
  resource := input.resource_changes[_]
  is_taggable_resource(resource.type)
  tags := get_tags(resource)
  env_tag := tags.Environment
  env_tag != null
  not valid_environment(env_tag)
  
  msg := sprintf(
    "🏷️ TAGGING: Resource '%s' has invalid Environment tag '%s'. Valid values: dev, staging, production",
    [resource.address, env_tag]
  )
}

# Policy: Project tag should follow naming convention
deny[msg] {
  resource := input.resource_changes[_]
  is_taggable_resource(resource.type)
  tags := get_tags(resource)
  project_tag := tags.Project
  project_tag != null
  not regex.match("^[a-z0-9-]+$", project_tag)
  
  msg := sprintf(
    "🏷️ TAGGING: Resource '%s' has invalid Project tag '%s'. Use lowercase alphanumeric with hyphens only.",
    [resource.address, project_tag]
  )
}

# Helper: Check if resource type supports tags
is_taggable_resource(resource_type) {
  taggable_types := {
    "aws_instance",
    "aws_ebs_volume",
    "aws_s3_bucket",
    "aws_vpc",
    "aws_subnet",
    "aws_security_group",
    "aws_db_instance",
    "aws_ecr_repository"
  }
  taggable_types[resource_type]
}

# Helper: Get tags from resource
get_tags(resource) := tags {
  tags := object.get(resource.change.after, "tags", {})
}

# Helper: Get missing required tags
get_missing_required_tags(resource) := missing {
  required_tags := {"Environment", "Project", "ManagedBy"}
  tags := get_tags(resource)
  missing := [tag | tag := required_tags[_]; not tags[tag]]
}

# Helper: Validate environment tag value
valid_environment(env) {
  valid_envs := {"dev", "staging", "production"}
  valid_envs[env]
}