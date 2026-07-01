provider "aws" {
  region = var.region

  # default_tags are stamped onto every taggable resource this provider creates,
  # so we never have to repeat Project/Environment/ManagedBy on each resource.
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
