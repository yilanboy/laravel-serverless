resource "aws_sqs_queue" "jobs" {
  name                       = "${var.app_name}-jobs-${var.resource_suffix}"
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.jobs_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })
}

resource "aws_sqs_queue" "jobs_dlq" {
  name                      = "${var.app_name}-jobs-dlq-${var.resource_suffix}"
  message_retention_seconds = 1209600
}
