data "aws_caller_identity" "current" {}

# One AZ from the target region for the EBS volume (and the optional instance).
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  az          = data.aws_availability_zones.available.names[0]

  # S3 bucket names are globally unique, so append the account id + region.
  bucket_name = "${local.name_prefix}-data-${data.aws_caller_identity.current.account_id}-${var.region}"
}

# ===========================================================================
# S3 access-log bucket — the target for the data bucket's server access logs.
# This is provided complete; use it as a worked example for the security blocks
# you must add to the DATA bucket below.
# ===========================================================================
resource "aws_s3_bucket" "logs" {
  # checkov:skip=CKV_AWS_18: This IS the access-log target bucket; it must not log to itself.
  # checkov:skip=CKV_AWS_144: Cross-region replication is out of scope for this lab.
  # checkov:skip=CKV_AWS_145: This lab teaches SSE-S3 (AES256), not customer-managed KMS.
  # checkov:skip=CKV2_AWS_62: Event notifications need an out-of-scope SNS/SQS/Lambda target.
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
# S3 DATA bucket — YOUR TASK is to secure this bucket.
# The bucket itself is created for you. Add the security controls below so that
# `terraform validate` and `checkov -d .` both pass.
# ===========================================================================
resource "aws_s3_bucket" "data" {
  # TODO(checkov): once you add the security blocks below, these skips stay as-is.
  # checkov:skip=CKV_AWS_144: Cross-region replication is out of scope for this lab.
  # checkov:skip=CKV_AWS_145: This lab teaches SSE-S3 (AES256), not customer-managed KMS.
  # checkov:skip=CKV2_AWS_62: Event notifications need an out-of-scope SNS/SQS/Lambda target.
  bucket = local.bucket_name

  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-data"
  }
}

# ---------------------------------------------------------------------------
# TODO 1: Enable versioning on aws_s3_bucket.data so overwrites/deletes are
#         recoverable. Resource type: aws_s3_bucket_versioning, name "data".
#         Set versioning_configuration { status = "Enabled" }.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# TODO 2: Encrypt the data bucket at rest with AES256 (SSE-S3).
#         Resource type: aws_s3_bucket_server_side_encryption_configuration,
#         name "data". Use sse_algorithm = "AES256" and bucket_key_enabled = true.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# TODO 3: Block ALL public access to the data bucket. Resource type:
#         aws_s3_bucket_public_access_block, name "data". Set all four flags
#         (block_public_acls, block_public_policy, ignore_public_acls,
#         restrict_public_buckets) to true.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# TODO 4: Add a lifecycle rule that expires NONCURRENT object versions after
#         var.noncurrent_version_expiration_days, and aborts incomplete
#         multipart uploads after 7 days. Resource type:
#         aws_s3_bucket_lifecycle_configuration, name "data".
#         Add depends_on = [<your versioning resource>].
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# TODO 5: Turn on server access logging for the data bucket, shipping logs to
#         aws_s3_bucket.logs with target_prefix = "s3-access-logs/". Resource
#         type: aws_s3_bucket_logging, name "data".
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# TODO 6: Attach a least-privilege bucket policy that DENIES any non-TLS request
#         (condition aws:SecureTransport = false) and DENIES PutObject without
#         server-side encryption (s3:x-amz-server-side-encryption != AES256).
#         Build it with a data "aws_iam_policy_document" "bucket" and attach via
#         aws_s3_bucket_policy "data" with depends_on the public access block.
# ---------------------------------------------------------------------------


# ===========================================================================
# DynamoDB — provided complete.
# ===========================================================================
resource "aws_dynamodb_table" "app" {
  # checkov:skip=CKV_AWS_119: SSE on with an AWS-owned key (free) satisfies the task.
  name         = "${local.name_prefix}-app"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "${local.name_prefix}-app"
  }
}

# ===========================================================================
# EBS — provided complete.
# ===========================================================================
resource "aws_ebs_volume" "data" {
  # checkov:skip=CKV_AWS_189: Encrypted with the default AWS-managed EBS key (free).
  availability_zone = local.az
  size              = var.ebs_volume_size_gb
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${local.name_prefix}-data-vol"
  }
}

# ===========================================================================
# Compute (GATED behind enable_compute, default OFF) — provided complete.
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

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  ebs_optimized = true
  monitoring    = true

  tags = {
    Name = "${local.name_prefix}-app"
  }
}
