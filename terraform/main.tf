locals {
  app_name = lower(replace(var.app_name, "/[^A-Za-z0-9]/", "-"))

  resolved_laravel_env_vars = var.ssm_parameter_name != "" ? jsondecode(data.aws_ssm_parameter.env[0].value) : {}

  dsql_cluster_endpoint = var.dsql_cluster_identifier != "" ? "${var.dsql_cluster_identifier}.dsql.${data.aws_region.current.region}.on.aws" : ""
  dsql_cluster_arn      = var.dsql_cluster_identifier != "" ? "arn:${data.aws_partition.current.partition}:dsql:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.dsql_cluster_identifier}" : ""
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

  dsql_cluster_endpoint = local.dsql_cluster_endpoint
  dsql_cluster_arn      = local.dsql_cluster_arn
  dsql_username         = var.dsql_username

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
