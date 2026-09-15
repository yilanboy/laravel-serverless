variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
}

variable "resource_suffix" {
  description = "Random suffix for unique resource naming"
  type        = string
}

variable "sqs_max_receive_count" {
  description = "Maximum number of times a message can be received before being sent to the DLQ"
  type        = number
  default     = 3
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue in seconds"
  type        = number
  default     = 360
}
