# ===========================================================================
# BROKEN FIXTURE — troubleshooting exercise.
#
# This configuration is syntactically valid: `terraform validate` SUCCEEDS.
# The defect is a SECURITY one that only a static scanner (checkov) catches:
# the bucket is made world-readable. `checkov -d .` fails with HIGH findings.
#
# DO NOT `terraform apply` this. Your job is to read the checkov output, find
# WHY the bucket is public, and fix it. The fix is in the solution/.
# ===========================================================================

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "broken-public-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "public" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = {
    Name = "broken-public-bucket"
  }
}

# DEFECT 1: public access block with EVERY flag turned OFF. This is the opposite
# of the secure baseline — it lets ACLs and bucket policies grant public access.
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.public.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "public" {
  bucket = aws_s3_bucket.public.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# DEFECT 2: a public-read ACL. Anyone on the internet can list and read objects.
resource "aws_s3_bucket_acl" "public" {
  depends_on = [
    aws_s3_bucket_ownership_controls.public,
    aws_s3_bucket_public_access_block.public,
  ]

  bucket = aws_s3_bucket.public.id
  acl    = "public-read"
}

# DEFECT 3: a bucket policy that allows s3:GetObject to "*" (everyone). Combined
# with the disabled public access block, this exposes every object publicly.
resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public]
}

# DEFECT 4: no encryption, no versioning, no logging, no lifecycle. The bucket is
# a wide-open, unencrypted dumping ground. checkov flags all of these too.
