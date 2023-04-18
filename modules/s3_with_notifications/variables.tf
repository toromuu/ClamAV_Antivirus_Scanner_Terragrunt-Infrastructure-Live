variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
}

variable "create_notification" {
  type        = bool
  default     = false
  description = "Whether to create a bucket notification"
}

variable "notification_lambda_function_arn" {
  type        = string
  default     = null
  description = "The ARN of the Lambda function to invoke for bucket notifications"
}

variable "notification_lambda_function_name" {
  type        = string
  default     = null
  description = "The name of the Lambda function to invoke for bucket notifications"
}


variable "create_lifecycle_configuration" {
  type        = bool
  default     = false
  description = "Whether to create a bucket lifecycle configuration"
}

variable "lifecycle_expiration_days" {
  type        = number
  default     = null
  description = "The number of days after which to expire objects in the bucket (if lifecycle configuration is enabled)"
}

variable "bucket_acl" {
  type    = string
  default = "private"
}

variable "tags" {
  type    = map(string)
  default = {}
}