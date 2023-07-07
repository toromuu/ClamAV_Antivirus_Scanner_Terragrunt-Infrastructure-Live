# The module will be reuse for Production & Quarantine so it has some resources optionals
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags   = var.tags
}

# Add permission to trigger/invoke lambda from notification 
resource "aws_lambda_permission" "allow_s3_invoke_lambda" {
  count         = var.create_notification ? 1 : 0
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = var.notification_lambda_function_name
  principal     = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.bucket.arn
}

# Define the trigger that is the object created in the bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.create_notification ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = var.notification_lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Good practice to encrypt bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# The buckets will be private, the user in the real case will upload using presigned URLs
resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.bucket_acl
}


resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# The objects that remain in the quarantine bucket will be deleted
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_configuration" {
  count = var.create_lifecycle_configuration ? 1 : 0

  rule {
    id     = "delete-objects-after-${var.lifecycle_expiration_days}-days"
    status = "Enabled"

    expiration {
      days = var.lifecycle_expiration_days
    }
  }

  bucket = aws_s3_bucket.bucket.id
}

