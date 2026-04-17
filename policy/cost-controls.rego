package terraform.cost_controls

# Policy: Restrict instance types in dev environment
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  contains(resource.address, "dev")
  not allowed_dev_instance_types[resource.change.after.instance_type]
  
  msg := sprintf(
    "❌ COST: Instance type '%s' not allowed in dev environment. Allowed types: t3.small, t3.medium, t3.large (found in: %s)",
    [resource.change.after.instance_type, resource.address]
  )
}

# Policy: Dev NAT gateways should be single-AZ (cost optimization)
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_nat_gateway"
  contains(resource.address, "dev")
  count_nat_gateways_dev > 1
  
  msg := sprintf(
    "❌ COST: Dev environment should use only 1 NAT gateway (found: %d). Use single_nat_gateway = true for cost optimization.",
    [count_nat_gateways_dev]
  )
}

# Policy: Karpenter should prefer Spot instances
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_eks_node_group"
  resource.change.after.capacity_type == "ON_DEMAND"
  not contains(resource.address, "production")
  not contains(resource.address, "managed")  # 🆕 Allow managed node groups to use ON_DEMAND
  
  msg := sprintf(
    "❌ COST: Node group '%s' using ON_DEMAND instances. Use Spot instances in non-production for 70%% cost savings.",
    [resource.address]
  )
}

# Policy: Prevent large EBS volumes in dev
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_ebs_volume"
  contains(resource.address, "dev")
  resource.change.after.size > 100
  
  msg := sprintf(
    "❌ COST: EBS volume size %d GB exceeds dev limit of 100 GB (found in: %s)",
    [resource.change.after.size, resource.address]
  )
}

# Helper: Allowed instance types for dev
allowed_dev_instance_types := {
  "t3.micro",
  "t3.small",
  "t3.medium",
  "t3.large"
}

# Helper: Count NAT gateways in dev
count_nat_gateways_dev := count([1 | 
  resource := input.resource_changes[_]
  resource.type == "aws_nat_gateway"
  contains(resource.address, "dev")
  resource.change.actions[_] == "create"
])