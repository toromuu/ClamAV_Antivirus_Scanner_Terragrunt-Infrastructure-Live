output "iam_role_name" {
  description = "The name of the IAM role."
  value       = aws_iam_role.lambda_role.name
}

output "iam_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
