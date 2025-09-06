output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint"
}

output "eks_cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Cluster security group ID"
}

output "eks_node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "Node group security group ID"
}

output "eks_oidc_issuer_url" {
  value       = module.eks.oidc_issuer_url
  description = "OIDC issuer URL (may be null if the upstream output name differs)"
}

output "eks_managed_nodegroups" {
  value       = module.eks.managed_nodegroups
  description = "Map of managed node groups keyed by your configured keys"
}
