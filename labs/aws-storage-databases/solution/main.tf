data "aws_caller_identity" "current" {}

# One AZ from the target region for the EBS volume (and the optional instance).
# Picking [0] keeps the volume and instance in the same AZ so they can attach.
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  az          = data.aws_availability_zones.available.names[0]

  # A deterministic, account/region-scoped bucket suffix. S3 bucket names are
  # globally unique, so we append the account id + region to the human prefix.
  bucket_name = "${local.name_prefix}-data-${data.aws_caller_identity.current.account_id}-${var.region}"
}

# ===========================================================================
# S3 access-log bucket — receives server access logs from the data bucket.
# Keeping logs in a separate, private, encrypted bucket is the AWS best practice
# (CKV_AWS_18). This bucket cannot log to itself (that would recurse), so the
# self-referential access-logging check is skipped here with a reason.
# ===========================================================================
resource "aws_s3_bucket" "logs" {
  # checkov:skip=CKV_AWS_18: This IS the access-log target bucket; it must not log
  # to itself (infinite recursion). The data bucket it serves is logged.
  # checkov:skip=CKV_AWS_144: Cross-region replication is out of scope for this
  # single-region, near-$0 storage lab; it would add a second region's storage cost.
  # checkov:skip=CKV_AWS_145: This lab deliberately teaches SSE-S3 (AES256); a
  # customer-managed KMS key is the documented "harden further" step, not the baseline.
  # checkov:skip=CKV2_AWS_62: Event notifications need an SNS/SQS/Lambda target that
  # is out of scope here; the bucket is otherwise locked down (private + encrypted).
  bucket = "${local.bucket_name}-logs"

  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-logs"
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Expire access logs so the logs bucket does not grow unbounded (CKV2_AWS_61).
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ===========================================================================
# S3 — object storage, secured to AWS best practice.
# The bucket itself is free; you pay only for stored data and requests, so an
# empty bucket created and destroyed in this lab costs effectively $0.
# ===========================================================================
resource "aws_s3_bucket" "data" {
  # checkov:skip=CKV_AWS_144: Cross-region replication is out of scope for this
  # single-region, near-$0 storage lab; it would add a second region's storage cost.
  # checkov:skip=CKV_AWS_145: This lab deliberately teaches SSE-S3 (AES256) as the
  # encryption baseline; switching to a customer-managed KMS key is the documented
  # "harden further" exercise in the README, not the default.
  # checkov:skip=CKV2_AWS_62: Event notifications need an SNS/SQS/Lambda target that
  # is out of scope for a storage primitives lab; the bucket is private + encrypted +
  # access-logged, which is the relevant security posture here.
  bucket = local.bucket_name

  # Allow `terraform destroy` to remove the bucket even if a learner left a few
  # test objects in it. Fine for a lab; set to false (or omit) for real data.
  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-data"
  }
}

# Server access logging — record every request against the data bucket into the
# dedicated logs bucket above (CKV_AWS_18, CIS best practice).
resource "aws_s3_bucket_logging" "data" {
  bucket = aws_s3_bucket.data.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# Keep every version of an object so accidental overwrites/deletes are recoverable.
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption at rest. AES256 (SSE-S3) is the zero-config, zero-cost
# baseline; swap to aws:kms with a customer key when you need key rotation/audit.
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block ALL public access at the bucket level. These four flags are the single
# most important S3 security control — they neutralise accidental public ACLs
# and policies regardless of what else is configured.
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle: expire noncurrent (overwritten/deleted) versions after N days, and
# abort incomplete multipart uploads so half-finished uploads don't accrue cost.
resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  # Lifecycle config depends on versioning being enabled first.
  depends_on = [aws_s3_bucket_versioning.data]

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {} # apply to all objects in the bucket

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Least-privilege bucket policy: deny any request that is not TLS-encrypted, and
# deny uploads that are not server-side encrypted. This hardens the bucket
# against plaintext transport and unencrypted writes without granting anyone new
# access (the bucket is private by default + locked by the public access block).
data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.data.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }
}

resource "aws_s3_bucket_policy" "data" {
  bucket = aws_s3_bucket.data.id
  policy = data.aws_iam_policy_document.bucket.json

  # The policy can only be applied after public access is blocked, otherwise the
  # block-public-policy guard may reject a policy with a "*" principal.
  depends_on = [aws_s3_bucket_public_access_block.data]
}

# ===========================================================================
# DynamoDB — serverless key/value table.
# PAY_PER_REQUEST (on-demand) means you pay per read/write with no provisioned
# capacity, so an idle table costs $0. PITR + SSE are the durability/security
# baseline.
# ===========================================================================
resource "aws_dynamodb_table" "app" {
  # checkov:skip=CKV_AWS_119: SSE is enabled with an AWS-owned key (free). The task
  # requires "SSE on"; a customer-managed CMK adds key cost/management and is the
  # documented harden-further step, not the near-$0 baseline this lab targets.
  name         = "${local.name_prefix}-app"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Point-in-time recovery: continuous backups for the last 35 days.
  point_in_time_recovery {
    enabled = true
  }

  # Encryption at rest. With no kms_key_arn this uses an AWS-owned key at no cost;
  # set kms_key_arn to a customer-managed key for audit/rotation control.
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "${local.name_prefix}-app"
  }
}

# ===========================================================================
# EBS — a standalone encrypted gp3 block volume. gp3 gives a baseline 3000 IOPS
# / 125 MiB/s decoupled from size, and is cheaper than gp2. 8 GiB ~= cents/month.
# Encryption at rest is mandatory here (CKV_AWS_3).
# ===========================================================================
resource "aws_ebs_volume" "data" {
  # checkov:skip=CKV_AWS_189: The volume is encrypted with the default AWS-managed
  # EBS key (free). A customer-managed CMK is the documented harden-further step;
  # the task requires only "gp3, encrypted", which this satisfies.
  availability_zone = local.az
  size              = var.ebs_volume_size_gb
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${local.name_prefix}-data-vol"
  }
}

# ===========================================================================
# Compute (GATED behind enable_compute, default OFF).
# A t3.micro that reads from the bucket and table via an instance profile. Off
# by default so the lab's default apply provisions only the (near-free) storage
# primitives above. Turn on only for the compute exercise, then destroy.
# ===========================================================================
data "aws_ami" "al2023" {
  count = var.enable_compute ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Trust policy: only the EC2 service may assume this role.
data "aws_iam_policy_document" "ec2_assume" {
  count = var.enable_compute ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  count = var.enable_compute ? 1 : 0

  name               = "${local.name_prefix}-instance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume[0].json

  tags = {
    Name = "${local.name_prefix}-instance"
  }
}

# Least-privilege access: read-only on THIS bucket and THIS table only — no "*"
# resources, no write/delete, no other tables or buckets.
data "aws_iam_policy_document" "instance" {
  count = var.enable_compute ? 1 : 0

  statement {
    sid    = "ReadDataBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*",
    ]
  }

  statement {
    sid    = "ReadAppTable"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:BatchGetItem",
    ]
    resources = [aws_dynamodb_table.app.arn]
  }
}

resource "aws_iam_role_policy" "instance" {
  count = var.enable_compute ? 1 : 0

  name   = "${local.name_prefix}-instance-read"
  role   = aws_iam_role.instance[0].id
  policy = data.aws_iam_policy_document.instance[0].json
}

resource "aws_iam_instance_profile" "instance" {
  count = var.enable_compute ? 1 : 0

  name = "${local.name_prefix}-instance"
  role = aws_iam_role.instance[0].name
}

resource "aws_instance" "app" {
  count = var.enable_compute ? 1 : 0

  ami                  = data.aws_ami.al2023[0].id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.instance[0].name

  # Harden the instance metadata service: require IMDSv2 (token-backed) so the
  # role's credentials can't be exfiltrated via SSRF against IMDSv1.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypt the root volume at rest.
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  # EBS-optimized + detailed monitoring are cheap good-practice defaults.
  ebs_optimized = true
  monitoring    = true

  tags = {
    Name = "${local.name_prefix}-app"
  }
}
