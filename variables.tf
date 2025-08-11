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
  default = "arn:aws:lambda:us-west-2:534081306603:layer:arm-php-84:29"
}

variable "console_lambda_layer_arn" {
  type    = string
  default = "arn:aws:lambda:us-west-2:534081306603:layer:console:110"
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

variable "app_env" {
  type    = string
  default = "production"
}

variable "app_key" {
  type      = string
  sensitive = true
}

variable "app_debug" {
  type    = bool
  default = false
}

variable "app_timezone" {
  type    = string
  default = "Asia/Taipei"
}

variable "app_locale" {
  type    = string
  default = "zh_TW"
}

variable "app_url" {
  type = string
}

variable "asset_url" {
  type = string
}

variable "database_connection" {
  type    = string
  default = "sqlite"
}

variable "database_host" {
  type     = string
  default  = null
  nullable = true
}

variable "database_port" {
  type     = number
  default  = null
  nullable = true
}

variable "database_name" {
  type    = string
  default = "/mnt/efs/db/database.sqlite"
}

variable "database_username" {
  type     = string
  default  = null
  nullable = true
}

variable "database_password" {
  type     = string
  default  = null
  nullable = true
}

variable "database_sslmode" {
  type    = string
  default = "require"
}

variable "cache_store" {
  type    = string
  default = "dynamodb"
}

variable "session_driver" {
  type    = string
  default = "dynamodb"
}

variable "session_lifetime" {
  type    = number
  default = 120
}

variable "queue_connection" {
  type    = string
  default = "sqs"
}

variable "filesystem_disk" {
  type    = string
  default = "s3"
}

variable "aws_bucket" {
  type = string
}

variable "aws_url" {
  type = string
}

variable "aws_use_path_style_endpoint" {
  type    = bool
  default = false
}

variable "captcha_site_key" {
  type    = string
  default = ""
}

variable "captcha_secret_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "mail_mailer" {
  type    = string
  default = "smtp"
}

variable "mail_host" {
  type = string
}

variable "mail_port" {
  type    = number
  default = 587
}

variable "mail_username" {
  type = string
}

variable "mail_password" {
  type      = string
  sensitive = true
}

variable "mail_from_address" {
  type = string
}

variable "scout_prefix" {
  type    = string
  default = ""
}

variable "algolia_app_id" {
  type    = string
  default = ""
}

variable "algolia_secret" {
  type      = string
  sensitive = true
  default   = ""
}
