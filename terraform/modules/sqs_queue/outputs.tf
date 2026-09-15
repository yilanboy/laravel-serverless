output "jobs_queue_url" {
  description = "URL of the jobs SQS queue"
  value       = aws_sqs_queue.jobs.id
}

output "jobs_queue_arn" {
  description = "ARN of the jobs SQS queue"
  value       = aws_sqs_queue.jobs.arn
}

output "jobs_dlq_url" {
  description = "URL of the jobs SQS dead letter queue"
  value       = aws_sqs_queue.jobs_dlq.id
}

output "jobs_dlq_arn" {
  description = "ARN of the jobs SQS dead letter queue"
  value       = aws_sqs_queue.jobs_dlq.arn
}
