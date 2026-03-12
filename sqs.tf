resource "aws_sqs_queue" "jobs" {
  name = "${local.app_name}-jobs-${random_string.resource_suffix.result}"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.jobs_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })
  visibility_timeout_seconds = 360
}

resource "aws_sqs_queue" "jobs_dlq" {
  message_retention_seconds = 1209600
  name                      = "${local.app_name}-jobs-dlq-${random_string.resource_suffix.result}"
}
