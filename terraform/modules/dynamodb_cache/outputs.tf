output "table_name" {
  description = "Name of the DynamoDB cache table"
  value       = aws_dynamodb_table.cache.name
}

output "table_arn" {
  description = "ARN of the DynamoDB cache table"
  value       = aws_dynamodb_table.cache.arn
}
