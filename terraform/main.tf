locals {
  app_name = lower(replace(var.app_name, "/[^A-Za-z0-9]/", "-"))

  resolved_laravel_env_vars = length(var.laravel_env_vars) > 0 ? var.laravel_env_vars : (
    var.environment_variables_json_file != "" && fileexists(var.environment_variables_json_file) ? jsondecode(file(var.environment_variables_json_file)) : {}
  )
}

resource "random_string" "resource_suffix" {
  length  = 6
  special = false
}

module "cache" {
  source          = "./modules/dynamodb_cache"
  app_name        = local.app_name
  resource_suffix = random_string.resource_suffix.result
}

module "queue" {
  source                = "./modules/sqs_queue"
  app_name              = local.app_name
  resource_suffix       = random_string.resource_suffix.result
  sqs_max_receive_count = var.sqs_max_receive_count
}

module "compute" {
  source = "./modules/laravel_compute"

  app_name                = local.app_name
  filename                = var.filename
  lambda_runtime          = var.lambda_runtime
  php_lambda_layer_arn    = var.php_lambda_layer_arn
  extra_lambda_layer_arns = var.extra_lambda_layer_arns
  lambda_memory_size      = var.lambda_memory_size
  log_retention_in_days   = var.log_retention_in_days

  enable_vpc         = var.enable_vpc
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  enable_filesystem = var.enable_filesystem
  access_point_arn  = var.access_point_arn

  dynamodb_table_name = module.cache.table_name
  dynamodb_table_arn  = module.cache.table_arn
  sqs_queue_url       = module.queue.jobs_queue_url
  sqs_queue_arn       = module.queue.jobs_queue_arn
  aws_bucket_arn      = data.aws_s3_bucket.main.arn

  laravel_env_vars = local.resolved_laravel_env_vars
}

module "api_gateway" {
  source = "./modules/api_gateway"

  app_name                         = local.app_name
  custom_domain_name               = var.custom_domain_name
  certificate_arn                  = var.certificate_arn
  web_function_name                = module.compute.web_lambda_function_name
  web_invoke_arn                   = module.compute.web_lambda_invoke_arn
  api_gateway_throttle_burst_limit = var.api_gateway_throttle_burst_limit
  api_gateway_throttle_rate_limit  = var.api_gateway_throttle_rate_limit
}
