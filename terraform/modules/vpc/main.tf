############################################
# VPC module - main.tf (updated)
############################################

data "aws_region" "current" {}

locals {
  common_tags = merge(
    var.tags,
    {
      Module    = "vpc"
      Component = "network"
    }
  )

  # Subnet tags required by EKS (cluster discovers subnets for ELB/ALB)
  # Assumes your EKS cluster name is "${var.name}-eks"
  eks_cluster_tag_key = "kubernetes.io/cluster/${var.name}-eks"

  # Interface VPC endpoints to create in private subnets
  interface_services = ["ecr.api", "ecr.dkr", "logs", "sts"]
}

# -----------------------
# Core networking
# -----------------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = "${var.name}-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-igw"
  })
}

# -----------------------
# Subnets (+ EKS-required tags)
# -----------------------
resource "aws_subnet" "public" {
  for_each = {
    for i, cidr in var.public_subnet_cidrs :
    i => { cidr = cidr, az = var.azs[i] }
  }

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                              = "${var.name}-public-${each.value.az}"
    Tier                              = "public"
    (local.eks_cluster_tag_key)       = "shared"
    "kubernetes.io/role/elb"          = "1"
  })
}

resource "aws_subnet" "private" {
  for_each = {
    for i, cidr in var.private_subnet_cidrs :
    i => { cidr = cidr, az = var.azs[i] }
  }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name                              = "${var.name}-private-${each.value.az}"
    Tier                              = "private"
    (local.eks_cluster_tag_key)       = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# -----------------------
# Routing
# -----------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-rt"
  })
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# One private RT per private subnet (no NAT; using VPC endpoints)
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-rt-${each.value.availability_zone}"
  })
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# -----------------------
# VPC Endpoints
# -----------------------

# S3 Gateway endpoint → attach to ALL private RTs
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private : rt.id]

  tags = merge(local.common_tags, {
    Name    = "${var.name}-s3-gateway"
    Service = "s3"
    Type    = "Gateway"
  })
}

# SG for Interface Endpoints (ENIs live in private subnets)
resource "aws_security_group" "vpce" {
  name        = "${var.name}-vpce-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Interface endpoints ENI SG"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-vpce-sg"
  })
}

# Interface endpoints in private subnets (ECR API/DKR, CloudWatch Logs, STS)
resource "aws_vpc_endpoint" "interfaces" {
  count               = var.create_interface_endpoints ? length(local.interface_services) : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${local.interface_services[count.index]}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]
  subnet_ids          = [for s in aws_subnet.private : s.id]

  tags = merge(local.common_tags, {
    Name    = "${var.name}-vpce-${local.interface_services[count.index]}"
    Service = local.interface_services[count.index]
    Type    = "Interface"
  })
}
