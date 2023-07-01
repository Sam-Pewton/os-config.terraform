variable "base-configs" {
  type = map(string)
  default = {
    profile = "default"
    region  = "eu-west-1"
  }
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones available"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

// VPC -> SUBNETS
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.1.1.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.1.2.0/24"]
}
