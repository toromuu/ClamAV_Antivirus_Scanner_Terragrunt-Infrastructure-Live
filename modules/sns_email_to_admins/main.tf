resource "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  count     = length(var.email_addresses)
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}