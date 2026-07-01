output "bucket_id" {
  description = "Name/ID of the created S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket. Marked sensitive so it is not echoed to the console or CI logs by default (use `terraform output -raw bucket_arn` to read it)."
  value       = aws_s3_bucket.this.arn
  sensitive   = true
}

output "bucket_domain_name" {
  description = "Regional domain name of the bucket (e.g. for SDK/CLI access)."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "kms_key_arn" {
  description = "ARN of the customer-managed KMS key encrypting the bucket. Sensitive — controls who can decrypt every object."
  value       = aws_kms_key.bucket.arn
  sensitive   = true
}
