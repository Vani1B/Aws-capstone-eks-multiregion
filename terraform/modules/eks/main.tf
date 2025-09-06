terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

locals {
  common_tags = merge(var.tags, {
    Module    = "eks"
    Component = "kubernetes"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true

  cluster_enabled_log_types              = ["api","audit","authenticator","controllerManager","scheduler"]
  cloudwatch_log_group_retention_in_days = 30

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  cluster_tags = merge(local.common_tags, { Name = var.name })

  eks_managed_node_group_defaults = {
    disk_size     = 50
    capacity_type = "ON_DEMAND"
    tags          = merge(local.common_tags, { NodeGroup = "default" })
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      tags           = merge(local.common_tags, { Name = "${var.name}-ng" })
    }
  }

  tags = local.common_tags
}
