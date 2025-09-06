# terraform/region-a-ca-central-1/main.tf
locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
    Region      = var.region
  }
}
module "vpc" {
  source                     = "../modules/vpc"
  name                       = var.name_prefix
  cidr_block                 = var.vpc_cidr
  azs                        = var.azs
  public_subnet_cidrs        = var.public_subnets
  private_subnet_cidrs       = var.private_subnets
  create_interface_endpoints = true
  tags                       = local.common_tags
}

module "eks" {
  source              = "../modules/eks"
  name                = "${var.name_prefix}-eks"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = var.eks_node_types
  desired_size        = var.eks_desired
  min_size            = var.eks_min
  max_size            = var.eks_max
  tags                = local.common_tags
}

module "rds" {
  source             = "../modules/rds"
  name               = var.name_prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  allowed_sg_id      = module.eks.cluster_security_group_id
  db_username        = var.db_username
  db_password        = var.db_password
  tags               = local.common_tags
}

