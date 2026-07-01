output "bucket_name" {
  description = "Name of the S3 data bucket."
  value       = aws_s3_bucket.data.id
}

output "bucket_arn" {
  description = "ARN of the S3 data bucket."
  value       = aws_s3_bucket.data.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
  value       = aws_dynamodb_table.app.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.app.arn
}

output "ebs_volume_id" {
  description = "ID of the standalone gp3 EBS volume."
  value       = aws_ebs_volume.data.id
}

output "instance_id" {
  description = "ID of the gated EC2 instance, or null when enable_compute is false."
  value       = var.enable_compute ? aws_instance.app[0].id : null
}

output "instance_profile_name" {
  description = "Name of the instance profile, or null when enable_compute is false."
  value       = var.enable_compute ? aws_iam_instance_profile.instance[0].name : null
}
