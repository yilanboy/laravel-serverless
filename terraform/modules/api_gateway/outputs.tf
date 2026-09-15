output "http_api_id" {
  description = "ID of the HTTP API"
  value       = aws_apigatewayv2_api.http_api.id
}

output "http_api_url" {
  description = "URL of the HTTP API"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "http_api_execution_arn" {
  description = "Execution ARN of the HTTP API"
  value       = aws_apigatewayv2_api.http_api.execution_arn
}
