variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
}

variable "custom_domain_name" {
  description = "Custom domain name for the API Gateway"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the AWS ACM certificate for the custom domain"
  type        = string
}

variable "web_function_name" {
  description = "Name of the web Lambda function"
  type        = string
}

variable "web_invoke_arn" {
  description = "Invocation ARN of the web Lambda function"
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
