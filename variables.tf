#
# provider settings
#
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "tag_service" {
  description = "Service name"
  type        = string
}

variable "tag_environment" {
  description = "Environment name"
  type        = string
}

variable "tag_owner" {
  description = "Owner name"
  type        = string
}

#
# lambda settings
#
variable "filename" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "./laravel-app.zip"
}

variable "lambda_runtime" {
  description = "Lambda runtime identifier (Bref uses custom runtime)"
  type        = string
  # https://bref.sh/docs/runtimes#aws-lambda-layers
  default = "provided.al2023"
}

variable "php_lambda_layer_arn" {
  description = "ARN of the Bref PHP Lambda layer"
  type        = string
  # check all php layer runtime in this page
  # https://runtimes.bref.sh/?region=us-west-2
  default = "arn:aws:lambda:us-west-2:873528684822:layer:arm-php-85:12"
}

variable "lambda_memory_size" {
  description = "Memory size in MB for all Lambda functions"
  type        = number
  default     = 1024
}

variable "enable_vpc" {
  description = "Whether to attach Lambda functions to a VPC"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC configuration (required when enable_vpc is true)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda VPC configuration (required when enable_vpc is true)"
  type        = list(string)
  default     = []
}

variable "enable_filesystem" {
  description = "Whether to mount an EFS filesystem to Lambda functions"
  type        = bool
  default     = false
}

variable "access_point_arn" {
  description = "ARN of the EFS access point (required when enable_filesystem is true)"
  type        = string
  default     = ""
}

#
# api gateway settings
#
variable "certificate_arn" {
  description = "ARN of the AWS ACM certificate for the custom domain"
  type        = string
}

variable "custom_domain_name" {
  description = "Custom domain name for the API Gateway (e.g. app.example.com)"
  type        = string
}

variable "api_gateway_throttle_burst_limit" {
  description = "API Gateway throttling burst limit"
  type        = number
  default     = 500
}

variable "api_gateway_throttle_rate_limit" {
  description = "API Gateway throttling rate limit"
  type        = number
  default     = 1000
}

#
# laravel settings
#
variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
}

#
# Lambda environment variables
#
variable "environment_variables_json_file" {
  description = "Path to the JSON file containing environment variables for the Lambda function."
  type        = string
}

#
# S3 settings
#
variable "aws_bucket" {
  description = "The name of the S3 bucket to store the Laravel application files."
  type        = string
}

#
# CloudWatch settings
#
variable "log_retention_in_days" {
  description = "Number of days to retain CloudWatch log events"
  type        = number
  default     = 1
}

#
# SQS settings
#
variable "sqs_max_receive_count" {
  description = "Maximum number of times a message can be received before being sent to the DLQ"
  type        = number
  default     = 3
}
