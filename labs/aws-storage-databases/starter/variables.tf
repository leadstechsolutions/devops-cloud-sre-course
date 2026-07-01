variable "project" {
  description = "Project name, used for tagging and as a prefix for resource names."
  type        = string
  default     = "aws-storage-db"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "project must be lowercase alphanumeric with hyphens only."
  }
}

variable "environment" {
  description = "Deployment environment. Constrained so a typo cannot create rogue infra."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "enable_compute" {
  description = <<-EOT
    If true, create the EC2 instance + instance profile that read from the bucket
    and table. Default false so a bare `terraform apply` provisions only storage
    primitives (S3, DynamoDB, an 8 GiB EBS volume) that cost cents/month. Flip to
    true only for the compute exercise, then destroy.
  EOT
  type        = bool
  default     = false
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which noncurrent S3 object versions are permanently deleted."
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days must be >= 1."
  }
}

variable "ebs_volume_size_gb" {
  description = "Size of the standalone gp3 EBS volume in GiB. Kept small to stay near $0."
  type        = number
  default     = 8

  validation {
    condition     = var.ebs_volume_size_gb >= 1 && var.ebs_volume_size_gb <= 100
    error_message = "ebs_volume_size_gb must be between 1 and 100 for this lab."
  }
}

variable "tags" {
  description = "Extra tags merged into provider default_tags and applied to all resources."
  type        = map(string)
  default     = {}
}
