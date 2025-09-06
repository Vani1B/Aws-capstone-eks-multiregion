variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}
variable "create_interface_endpoints" {
  type    = bool
  default = true
}

# NEW
variable "tags" {
  type    = map(string)
  default = {}
}

