variable "name" {
  type        = string
  description = "Name prefix for DB resources"
}

variable "engine_version" {
  type        = string
  default     = "8.0.39"
  description = "MySQL engine version"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "DB instance class"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for DB subnet group"
}

variable "allowed_sg_id" {
  type        = string
  description = "Security group ID allowed to access DB (EKS node SG recommended)"
}

variable "db_username" {
  type        = string
  default     = "appuser"
  description = "DB master username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "DB master password"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags"
}

