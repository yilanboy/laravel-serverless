output "web_lambda_arn" {
  description = "ARN of the web Lambda function"
  value       = aws_lambda_function.web.arn
}

output "web_lambda_function_name" {
  description = "Name of the web Lambda function"
  value       = aws_lambda_function.web.function_name
}

output "web_lambda_invoke_arn" {
  description = "Invoke ARN of the web Lambda function"
  value       = aws_lambda_function.web.invoke_arn
}

output "web_lambda_function_version" {
  description = "Current version of the web Lambda function"
  value       = aws_lambda_function.web.version
}

output "artisan_lambda_function_version" {
  description = "Current version of the artisan Lambda function"
  value       = aws_lambda_function.artisan.version
}

output "jobs_worker_lambda_function_version" {
  description = "Current version of the jobs worker Lambda function"
  value       = aws_lambda_function.jobs_worker.version
}
