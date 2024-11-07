variable "app_name" {
  type = string
}

# provider settings
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

# lambda settings
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
  # https://runtimes.bref.sh/?region=us-west-2&version=2.3.9
  default = "arn:aws:lambda:us-west-2:534081306603:layer:arm-php-83:38"
}

variable "console_lambda_layer_arn" {
  type    = string
  default = "arn:aws:lambda:us-west-2:534081306603:layer:console:91"
}

# laravel settings
variable "app_key" {
  type      = string
  sensitive = true
}

variable "app_url" {
  type = string
}

variable "asset_url" {
  type = string
}

variable "database_host" {
  type = string
}

variable "database_port" {
  type = number
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type = string
}

variable "database_sslmode" {
  type    = string
  default = "require"
}

variable "aws_bucket" {
  type = string
}

variable "aws_url" {
  type = string
}

variable "captcha_site_key" {
  type = string
}

variable "captcha_secret_key" {
  type      = string
  sensitive = true
}

variable "mail_password" {
  type      = string
  sensitive = true
}

variable "scout_prefix" {
  type = string
}

variable "algolia_app_id" {
  type = string
}

variable "algolia_secret" {
  type      = string
  sensitive = true
}

# api gateway settings
variable "certificate_arn" {
  type = string
}

variable "custom_domain_name" {
  type = string
}
