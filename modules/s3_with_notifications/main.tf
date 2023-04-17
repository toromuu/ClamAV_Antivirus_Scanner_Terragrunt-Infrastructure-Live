resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name  
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count   = var.create_notification ? 1 : 0
  bucket  = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = var.notification_lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.example.id
  acl    = var.bucket_acl
}


resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_configuration" {
  rule {
    id      = "delete-objects-after-1-week"
    status  = "Enabled"

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_configuration" {
  count = var.create_lifecycle_configuration ? 1 : 0

  rule {
    id      = "delete-objects-after-${var.lifecycle_expiration_days}-days"
    status  = "Enabled"

    expiration {
      days = var.lifecycle_expiration_days
    }
  }

  bucket = aws_s3_bucket.bucket.id
}

