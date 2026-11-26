locals {
  dsql_env_vars = var.dsql_cluster_endpoint != "" ? {
    DB_CONNECTION = "dsql"
    DB_HOST       = var.dsql_cluster_endpoint
    DB_PORT       = "5432"
    DB_DATABASE   = "postgres"
    DB_USERNAME   = var.dsql_username
  } : {}

  common_env_vars = merge(
    var.laravel_env_vars,
    {
      LOG_CHANNEL          = "stderr"
      LOG_STDERR_FORMATTER = "Bref\\Monolog\\CloudWatchFormatter"
      CACHE_STORE          = "dynamodb"
      DYNAMODB_CACHE_TABLE = var.dynamodb_table_name
      QUEUE_CONNECTION     = "sqs"
      SQS_QUEUE            = var.sqs_queue_url
    },
    local.dsql_env_vars
  )
}

resource "aws_lambda_function" "web" {
  filename         = var.filename
  source_code_hash = fileexists(var.filename) ? filesha256(var.filename) : null
  handler          = "Bref\\LaravelBridge\\Http\\OctaneHandler"
  runtime          = var.lambda_runtime
  function_name    = "${var.app_name}-web"
  memory_size      = var.lambda_memory_size
  timeout          = 28
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = concat([var.php_lambda_layer_arn], var.extra_lambda_layer_arns)

  environment {
    variables = merge(
      local.common_env_vars,
      {
        BREF_RUNTIME                     = "Bref\\FunctionRuntime\\Main"
        BREF_LOOP_MAX                    = "250"
        OCTANE_PERSIST_DATABASE_SESSIONS = "1"
      }
    )
  }
}

resource "aws_lambda_function" "artisan" {
  filename         = var.filename
  source_code_hash = fileexists(var.filename) ? filesha256(var.filename) : null
  handler          = "artisan"
  runtime          = var.lambda_runtime
  function_name    = "${var.app_name}-artisan"
  memory_size      = var.lambda_memory_size
  timeout          = 720
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = concat([var.php_lambda_layer_arn], var.extra_lambda_layer_arns)

  environment {
    variables = merge(
      local.common_env_vars,
      {
        BREF_RUNTIME = "Bref\\ConsoleRuntime\\Main"
      }
    )
  }
}

resource "aws_lambda_function" "jobs_worker" {
  filename         = var.filename
  source_code_hash = fileexists(var.filename) ? filesha256(var.filename) : null
  handler          = "Bref\\LaravelBridge\\Queue\\QueueHandler"
  runtime          = var.lambda_runtime
  function_name    = "${var.app_name}-jobs-worker"
  memory_size      = var.lambda_memory_size
  timeout          = 60
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = concat([var.php_lambda_layer_arn], var.extra_lambda_layer_arns)

  environment {
    variables = merge(
      local.common_env_vars,
      {
        BREF_RUNTIME = "Bref\\FunctionRuntime\\Main"
      }
    )
  }
}

resource "aws_lambda_permission" "artisan_events_rule_schedule" {
  function_name = aws_lambda_function.artisan.function_name
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.artisan_schedule.arn
}

resource "aws_lambda_event_source_mapping" "jobs_worker_sqs" {
  batch_size                         = 1
  maximum_batching_window_in_seconds = 0
  event_source_arn                   = var.sqs_queue_arn
  function_name                      = aws_lambda_function.jobs_worker.function_name
  enabled                            = true
  bisect_batch_on_function_error     = false
  function_response_types = [
    "ReportBatchItemFailures"
  ]
}
