variable "email_addresses" {
  type        = list(string)
  description = "The list of email addresses to send notifications to."
}

variable "sns_topic_name" {
  description = "Name of the SNS topic to create."
  type        = string
}
