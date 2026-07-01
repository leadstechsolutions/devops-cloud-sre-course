variable "project" {
  description = "Project name, used as a prefix in Name tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment, used in Name tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "List of AZ names to place subnets in. One public + one private subnet per AZ."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 1
    error_message = "availability_zones must contain at least one AZ."
  }
}

variable "enable_nat_gateway" {
  description = "If true, create a single NAT gateway + EIP and route private subnets through it."
  type        = bool
  default     = false
}
