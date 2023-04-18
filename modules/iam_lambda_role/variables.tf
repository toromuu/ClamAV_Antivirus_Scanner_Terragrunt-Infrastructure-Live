variable "role_name" {
  description = "The name of the IAM role for the Lambda function."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}