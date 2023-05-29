# Assume role that will take the lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = var.role_name
}

# resource "aws_iam_role_policy_attachment" "s3_full_access" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#   role = var.role_name
# }

# resource "aws_iam_role_policy_attachment" "ecr_full_access" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
#   role = var.role_name
# }


# Create a new policy
resource "aws_iam_policy" "access_policy" {
  name        = "access_policy"
  description = "Allows access for ClamAV object parsing and tagging"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObjectTagging",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::production-clamav-antivirus-scanner-test",
          "arn:aws:s3:::quarantine-clamav-antivirus-scanner-test",
          "arn:aws:s3:::production-clamav-antivirus-scanner-test/*",
          "arn:aws:s3:::quarantine-clamav-antivirus-scanner-test/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage"
        ]
        Resource = [
          "arn:aws:ecr:::clamav_antivirus_scanner_repository"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          "arn:aws:sns:us-east-1:153262203368:emailtoAdmins"
        ]
      }
    ]
  })
}


# //No granuality to avoid recursive dependency cycle
# //arn:aws:s3:::production-clamav-antivirus-scanner-test
# //arn:aws:s3:::quarantine-clamav-antivirus-scanner-test
#          "arn:aws:s3:::${s3_production_name}",
#          "arn:aws:s3:::${s3_quarantine_name}",
#          "arn:aws:ecr:::${ecr_repo_name}",
#          "arn:aws:sns:::${sns_name}"

# Attach new policy to role
resource "aws_iam_role_policy_attachment" "s3_access" {
  policy_arn = aws_iam_policy.access_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}


