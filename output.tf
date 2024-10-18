output "web_lambda_function_qualified_arn" {
  description = "Current Lambda function version"
  value       = aws_lambda_function.web_lambda_function.version
}

output "artisan_lambda_function_qualified_arn" {
  description = "Current Lambda function version"
  value       = aws_lambda_function.artisan_lambda_function.version
}

output "jobs_worker_lambda_function_qualified_arn" {
  description = "Current Lambda function version"
  value       = aws_lambda_function.jobs_worker_lambda_function.version
}

output "http_api_id" {
  description = "Id of the HTTP API"
  value       = aws_apigatewayv2_api.http_api.id
}

output "http_api_url" {
  description = "URL of the HTTP API"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "jobs_queue_arn" {
  description = "ARN of the \"jobs\" SQS queue."
  value       = aws_sqs_queue.jobs_queue.arn
}

output "jobs_queue_url" {
  description = "URL of the \"jobs\" SQS queue."
  value       = aws_sqs_queue.jobs_queue.id
}

output "jobs_dlq_url" {
  description = "URL of the \"jobs\" SQS dead letter queue."
  value       = aws_sqs_queue.jobs_dlq.id
}
