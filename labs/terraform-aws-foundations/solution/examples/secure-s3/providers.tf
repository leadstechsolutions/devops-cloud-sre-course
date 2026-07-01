provider "aws" {
  region = var.region

  # default_tags are applied to every taggable resource the provider creates.
  # Per-resource Name tags are merged on top of these in main.tf.
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
