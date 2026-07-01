# ---------------------------------------------------------------------------
# Secure S3 bucket — STARTER. This is the Week 14 lecture demo, but the security
# controls are left for you to add. A bare aws_s3_bucket is the misconfiguration
# that shows up in breach post-mortems: since AWS provider v4 it is unencrypted,
# unversioned, and only implicitly non-public. Your job is to attach the
# controls that make it safe, by filling in every TODO(student) block below.
#
# Check yourself against ../../../solution/examples/secure-s3/ and run the lab's
# validate.sh from the module root. The starter `terraform validate`s as-is
# (the bucket and key are valid on their own), but it is NOT secure until you
# complete the TODOs — checkov on the starter will report failures by design.
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
}

# Read-only lookup: who is running Terraform right now? (A data source creates
# nothing.) Used to tag the bucket with the owning account.
data "aws_caller_identity" "current" {}

# Customer-managed KMS key used to encrypt objects at rest (SSE-KMS). Provided
# for you — you will reference it from the encryption block you add below.
resource "aws_kms_key" "bucket" {
  description             = "${local.name_prefix} S3 bucket encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAccountAdmin"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowS3UseOfTheKey"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
      },
    ]
  })

  tags = {
    Name = "${local.name_prefix}-s3-kms"
  }
}

resource "aws_kms_alias" "bucket" {
  name          = "alias/${local.name_prefix}-s3"
  target_key_id = aws_kms_key.bucket.key_id
}

# The bucket itself.
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name             = var.bucket_name
    CreatedByAccount = data.aws_caller_identity.current.account_id
  }
}

# ===========================================================================
# TODO(student): add the security controls below. Each references
# aws_s3_bucket.this.id — that is the dependency graph in action (Terraform
# creates the bucket first, then attaches each control).
# ===========================================================================

# TODO(student) 1 — BLOCK PUBLIC ACCESS (the single most important S3 control).
#   resource "aws_s3_bucket_public_access_block" "this" {
#     bucket = aws_s3_bucket.this.id
#     block_public_acls       = true
#     block_public_policy     = true
#     ignore_public_acls      = true
#     restrict_public_buckets = true
#   }

# TODO(student) 2 — ENCRYPT AT REST with the customer-managed KMS key above.
#   resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
#     bucket = aws_s3_bucket.this.id
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm     = "aws:kms"
#         kms_master_key_id = aws_kms_key.bucket.arn
#       }
#       bucket_key_enabled = true
#     }
#   }

# TODO(student) 3 — VERSIONING so deletes/overwrites are recoverable.
#   resource "aws_s3_bucket_versioning" "this" {
#     bucket = aws_s3_bucket.this.id
#     versioning_configuration {
#       status = "Enabled"
#     }
#   }

# TODO(student) 4 — BUCKET POLICY that denies non-TLS requests and any upload
#   that is not encrypted with aws:kms. See the solution for the two Deny
#   statements (aws:SecureTransport = false; s3:x-amz-server-side-encryption !=
#   aws:kms). Add `depends_on = [aws_s3_bucket_public_access_block.this]`.

# TODO(student) 5 — LIFECYCLE rule to abort incomplete multipart uploads after
#   7 days (aws_s3_bucket_lifecycle_configuration, filter {} +
#   abort_incomplete_multipart_upload { days_after_initiation = 7 }).

# TODO(student) 6 — ACCESS LOGGING into a separate, equally-hardened log bucket,
#   plus EventBridge notifications (aws_s3_bucket_notification eventbridge =
#   true). This is the senior-grade observability step — see the solution for
#   the full log-bucket stack and aws_s3_bucket_logging on this bucket.

# Once every TODO is filled, `terraform validate` should still pass AND
# `checkov -d . --compact` should report 0 failed checks (the solution does).
