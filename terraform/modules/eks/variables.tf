variable "name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS and nodegroups"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Instance types for the default managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired nodes in the default node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Min nodes in the default node group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Max nodes in the default node group"
  type        = number
  default     = 4
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
  default     = {}
}
