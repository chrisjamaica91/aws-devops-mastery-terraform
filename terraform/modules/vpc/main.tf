# ==========================================
# VPC Module for EKS
# ==========================================
# Creates a production-grade VPC with:
# - Public subnets (for load balancers, NAT gateways)
# - Private subnets (for EKS nodes, pods, databases)
# - Multi-AZ for high availability
# - Proper tagging for EKS auto-discovery

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ==========================================
# Data Sources
# ==========================================

# Get available AZs in current region
data "aws_availability_zones" "available" {
  state = "available"
}

# ==========================================
# VPC
# ==========================================

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # Required for EKS
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
      # Required for EKS to discover the VPC
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

# ==========================================
# Internet Gateway (for public subnets)
# ==========================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# ==========================================
# Public Subnets (for load balancers, NAT gateway)
# ==========================================

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  # Auto-assign public IPs to resources in this subnet
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-public-${data.aws_availability_zones.available.names[count.index]}"
      # Tell EKS this is a public subnet (for load balancers)
      "kubernetes.io/role/elb" = "1"
      # Required for EKS
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

# ==========================================
# Private Subnets (for EKS nodes, pods, databases)
# ==========================================

resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-private-${data.aws_availability_zones.available.names[count.index]}"
      # Tell EKS this is a private subnet (for internal load balancers)
      "kubernetes.io/role/internal-elb" = "1"
      # Required for EKS
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      # ADD THIS TAG for Karpenter discovery of private subnets:
      "karpenter.sh/discovery" = var.cluster_name
    }
  )
}

# ==========================================
# Elastic IPs for NAT Gateways
# ==========================================

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ==========================================
# NAT Gateways (for private subnet internet access)
# ==========================================

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-${data.aws_availability_zones.available.names[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ==========================================
# Route Table for Public Subnets
# ==========================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
    }
  )
}

# Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# Route Tables for Private Subnets
# ==========================================

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.project_name}-${var.environment}-private-${data.aws_availability_zones.available.names[count.index]}"
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

# Route to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}
