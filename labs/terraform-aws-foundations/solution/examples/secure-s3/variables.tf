variable "project" {
  description = "Project name, used for tagging and resource naming prefixes."
  type        = string
  default     = "tf-aws-foundations"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "project must be lowercase alphanumeric with hyphens only."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
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

variable "bucket_name" {
  description = <<-EOT
    Globally unique S3 bucket name. S3 bucket names must be 3-63 characters,
    lowercase letters, numbers, dots and hyphens only, and must start and end
    with a letter or number. Pick something unique (e.g. add your initials and a
    date suffix) — two AWS accounts cannot share a bucket name.
  EOT
  type        = string

  validation {
    # Length bound: S3 requires 3-63 characters.
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "bucket_name must be between 3 and 63 characters long."
  }

  validation {
    # Character/shape bound: lowercase DNS-style name, no leading/trailing
    # separator, no uppercase, and not formatted like an IP address.
    condition = (
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name)) &&
      !can(regex("^[0-9]+(\\.[0-9]+){3}$", var.bucket_name))
    )
    error_message = "bucket_name must be a valid lowercase S3 name (a-z, 0-9, '.', '-'; start/end alphanumeric; not an IP address)."
  }
}

variable "force_destroy" {
  description = <<-EOT
    If true, `terraform destroy` will delete the bucket even when it still
    contains objects (and all object versions). Leave false for anything you
    care about; set true only for throwaway lab buckets so cleanup never gets
    stuck on a non-empty, versioned bucket.
  EOT
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags merged into provider default_tags and applied to all resources."
  type        = map(string)
  default     = {}
}
