output "bucket_id" {
  description = "The ID of the S3 bucket created"
  value       = try(aws_s3_bucket.bucket.id, "")
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket created"
  value       = try(aws_s3_bucket.bucket.arn, "")
}