output "web_lambda_function_version" {
  description = "Current version of the web Lambda function"
  value       = module.compute.web_lambda_function_version
}

output "artisan_lambda_function_version" {
  description = "Current version of the artisan Lambda function"
  value       = module.compute.artisan_lambda_function_version
}

output "jobs_worker_lambda_function_version" {
  description = "Current version of the jobs worker Lambda function"
  value       = module.compute.jobs_worker_lambda_function_version
}

output "http_api_id" {
  description = "Id of the HTTP API"
  value       = module.api_gateway.http_api_id
}

output "http_api_url" {
  description = "URL of the HTTP API"
  value       = module.api_gateway.http_api_url
}

output "jobs_queue_arn" {
  description = "ARN of the jobs SQS queue"
  value       = module.queue.jobs_queue_arn
}

output "jobs_queue_url" {
  description = "URL of the jobs SQS queue"
  value       = module.queue.jobs_queue_url
}

output "jobs_dlq_url" {
  description = "URL of the jobs SQS dead letter queue"
  value       = module.queue.jobs_dlq_url
}
