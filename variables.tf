#
# provider settings
#
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
  type    = string
  default = "./laravel-app.zip"
}

variable "lambda_runtime" {
  type = string
  # https://bref.sh/docs/runtimes#aws-lambda-layers
  default = "provided.al2"
}

variable "php_lambda_layer_arn" {
  type = string
  # check all php layer runtime in this page
  # https://runtimes.bref.sh/?region=us-west-2
  default = "arn:aws:lambda:us-west-2:534081306603:layer:arm-php-84:36"
}

variable "console_lambda_layer_arn" {
  type    = string
  default = "arn:aws:lambda:us-west-2:534081306603:layer:console:117"
}

variable "enable_vpc" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "enable_filesystem" {
  type    = bool
  default = false
}

variable "access_point_arn" {
  type = string
}


#
# api gateway settings
#
variable "certificate_arn" {
  type = string
}

variable "custom_domain_name" {
  type = string
}

#
# laravel settings
#
variable "app_name" {
  type = string
}

#
# Lambda environment variables
#
variable "environment_variables_json_file" {
  type        = string
  description = "Path to the JSON file containing environment variables for the Lambda function."
}

#
# S3 settings
#
variable "aws_bucket" {
  type        = string
  description = "The name of the S3 bucket to store the Laravel application files."
}
