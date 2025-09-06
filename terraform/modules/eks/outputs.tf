# terraform/modules/eks/outputs.tf

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Worker node security group ID"
  value       = module.eks.node_security_group_id
}

# Works across versions (some expose cluster_oidc_issuer_url, others cluster_oidc_issuer)
output "oidc_issuer_url" {
  description = "OIDC issuer URL"
  value       = try(module.eks.cluster_oidc_issuer_url, module.eks.cluster_oidc_issuer, null)
}

# v20 exposes a rich map of MNGs; convenience maps (…_arns / …_ids) may not exist.
output "managed_nodegroups" {
  description = "Map of managed node group objects keyed by node group key (e.g., \"default\")"
  value       = try(module.eks.eks_managed_node_groups, {})
}
