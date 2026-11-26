variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
}

variable "filename" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "./laravel-app.zip"
}

variable "lambda_runtime" {
  description = "Lambda runtime identifier (Bref uses custom runtime)"
  type        = string
  default     = "provided.al2023"
}

variable "php_lambda_layer_arn" {
  description = "ARN of the Bref PHP Lambda layer"
  type        = string
  default     = "arn:aws:lambda:us-west-2:873528684822:layer:arm-php-85:18"
}

variable "extra_lambda_layer_arns" {
  description = "Additional Lambda layer ARNs to attach alongside the Bref PHP layer"
  type        = list(string)
  default     = []
}

variable "lambda_memory_size" {
  description = "Memory size in MB for all Lambda functions"
  type        = number
  default     = 1024
}

variable "dsql_cluster_endpoint" {
  description = "PostgreSQL-compatible endpoint of the Amazon Aurora DSQL cluster (leave empty to skip DSQL env injection)"
  type        = string
  default     = ""
}

variable "dsql_cluster_arn" {
  description = "ARN of the Amazon Aurora DSQL cluster (leave empty to skip DSQL IAM permissions)"
  type        = string
  default     = ""
}

variable "dsql_username" {
  description = "Database username for Amazon Aurora DSQL"
  type        = string
  default     = "admin"
}

variable "log_retention_in_days" {
  description = "Number of days to retain CloudWatch log events"
  type        = number
  default     = 1
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB cache table"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB cache table"
  type        = string
}

variable "sqs_queue_url" {
  description = "URL of the jobs SQS queue"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the jobs SQS queue"
  type        = string
}

variable "aws_bucket_arn" {
  description = "ARN of the S3 bucket for application files"
  type        = string
}

variable "laravel_env_vars" {
  description = "Application environment variables for Laravel"
  type        = map(string)
  default     = {}
  sensitive   = true
}
