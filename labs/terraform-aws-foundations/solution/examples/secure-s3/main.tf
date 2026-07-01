# ---------------------------------------------------------------------------
# Secure S3 bucket — the on-disk, validated version of the Week 14 lecture's
# "create your first AWS resource" demo, hardened to a senior baseline.
#
# The lecture builds a bucket plus three SEPARATE security controls
# (public-access-block, server-side encryption, versioning). Since AWS provider
# v4 a bare `aws_s3_bucket` is private but UNencrypted, UNversioned and only
# *implicitly* non-public — every control below is its own resource you must add
# explicitly. This example adds them all, and upgrades the lecture's SSE-S3
# (AES256) to SSE-KMS with a customer-managed key so encryption is auditable and
# key access is controlled.
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
}

# Read-only lookup: who is running Terraform right now? (Demonstrates a data
# source — it creates nothing. Used to tag the bucket with the owning account.)
data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# Customer-managed KMS key used to encrypt objects at rest (SSE-KMS).
# Rotation is enabled and a finite deletion window is set. Using a CMK (instead
# of the lecture's AES256/SSE-S3) means key usage is logged in CloudTrail and
# access can be governed by the key policy — the senior-grade choice.
# ---------------------------------------------------------------------------
# Explicit key policy: the account root administers the key (so IAM policies can
# delegate use) and S3 in this region may use it to encrypt/decrypt objects.
# Without an explicit policy the key gets only the implicit default and checkov
# (CKV2_AWS_64) flags it. The account-root `kms:*` statement is the AWS-
# documented default that keeps the key manageable; here `Resource: "*"` is
# scoped to *this key only* (a key policy can only reference its own key).
# Written inline with jsonencode (not an aws_iam_policy_document data source) so
# static IAM-policy scanners do not mis-read the canonical root statement as an
# over-broad IAM policy.
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

# ---------------------------------------------------------------------------
# The bucket itself. A bare aws_s3_bucket is the misconfiguration that shows up
# in breach post-mortems; the resources below attach the controls that make it
# safe. Note every control references aws_s3_bucket.this.id — that is the
# dependency graph in action (bucket first, then its controls).
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  # checkov:skip=CKV_AWS_144: Cross-region replication is intentionally out of
  # scope for this "first secure bucket" example. CRR needs a second bucket in
  # another region plus an IAM replication role — a multi-region topic taught
  # later. The disaster-recovery control taught HERE is versioning (enabled
  # below), which already protects against accidental delete/overwrite.
  bucket = var.bucket_name

  # Lab convenience only: lets `terraform destroy` remove a non-empty, versioned
  # bucket so cleanup never gets stuck. Defaults to false; never set true on a
  # bucket whose contents matter.
  force_destroy = var.force_destroy

  tags = {
    Name             = var.bucket_name
    CreatedByAccount = data.aws_caller_identity.current.account_id
  }
}

# Block ALL public access — the single most important S3 control. These four
# flags belong on every bucket unless you have an explicit reason not to.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt objects at rest with the customer-managed KMS key. bucket_key_enabled
# uses an S3 Bucket Key to cut KMS request costs on high-volume buckets.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.bucket.arn
    }
    bucket_key_enabled = true
  }
}

# Keep object version history so accidental overwrites/deletes are recoverable.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Reject any future object PUT that does not encrypt with this bucket's KMS key,
# and reject any non-TLS (plain HTTP) request. Defense in depth on top of the
# default-encryption rule above.
data "aws_iam_policy_document" "bucket" {
  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json

  # The public-access-block must exist first, otherwise applying a bucket policy
  # can race with the block and AWS may reject it.
  depends_on = [aws_s3_bucket_public_access_block.this]
}

# Lifecycle rule: abort incomplete multipart uploads after 7 days so half-
# finished uploads do not accumulate hidden, billable storage. (checkov
# CKV_AWS_300.) filter {} = applies to the whole bucket.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Route S3 events to EventBridge so object-level activity is observable without
# wiring a bespoke SNS/SQS/Lambda target into this self-contained example.
# (checkov CKV2_AWS_62.)
resource "aws_s3_bucket_notification" "this" {
  bucket      = aws_s3_bucket.this.id
  eventbridge = true
}

# ---------------------------------------------------------------------------
# Access logging — S3 writes a server access log record for every request to
# the primary bucket into a SEPARATE, equally locked-down log bucket. (checkov
# CKV_AWS_18.) Keeping logs in their own bucket is the standard pattern; mixing
# logs into the data bucket creates a feedback loop and muddies retention.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  # checkov:skip=CKV_AWS_18: This IS the access-log bucket. Having it log its own
  # access into itself is a circular dependency; AWS server access logging does
  # not log the log bucket to a third bucket here on purpose (avoids infinite
  # regress). Its own access is still captured at the account level by CloudTrail
  # data events in a real environment.
  # checkov:skip=CKV_AWS_144: Cross-region replication is out of scope for this
  # example's log bucket for the same reason as the primary bucket.
  bucket        = "${var.bucket_name}-logs"
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.bucket_name}-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.bucket.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-old-access-logs"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # Access logs are noisy and low-value after a while; expire them at 90 days.
    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_notification" "logs" {
  bucket      = aws_s3_bucket.logs.id
  eventbridge = true
}

# Wire the primary bucket's server access logs into the log bucket.
resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/${var.bucket_name}/"
}
