output "iam_role_name" {
  description = "The name of the IAM role."
  value       = try(aws_iam_role.lambda_execution_role.name, "")
}

output "iam_role_arn" {
  value = try(aws_iam_role.lambda_execution_role.arn, "")
}
