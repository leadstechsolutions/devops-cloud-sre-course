provider "aws" {
  region = var.region

  # default_tags are applied to every taggable resource created by this provider.
  # Per-resource Name tags are merged on top of these in the vpc module.
  default_tags {
    tags = merge(
      {
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags,
    )
  }
}
