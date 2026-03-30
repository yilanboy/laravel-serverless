resource "aws_lambda_function" "web" {
  filename         = var.filename
  source_code_hash = filesha256(var.filename)
  handler          = "Bref\\LaravelBridge\\Http\\OctaneHandler"
  runtime          = var.lambda_runtime
  function_name    = "${local.app_name}-web"
  memory_size      = var.lambda_memory_size
  timeout          = 28
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = [var.php_lambda_layer_arn]

  environment {
    variables = merge(
      jsondecode(file(var.environment_variables_json_file)),
      {
        BREF_RUNTIME                     = "Bref\\FunctionRuntime\\Main"
        BREF_LOOP_MAX                    = "250"
        OCTANE_PERSIST_DATABASE_SESSIONS = "1"
        LOG_CHANNEL                      = "stderr"
        LOG_STDERR_FORMATTER             = "Bref\\Monolog\\CloudWatchFormatter"
        DYNAMODB_CACHE_TABLE             = aws_dynamodb_table.cache.name
        SQS_PREFIX                       = aws_sqs_queue.jobs.url
        SQS_QUEUE                        = aws_sqs_queue.jobs.url
      }
    )
  }

  dynamic "vpc_config" {
    for_each = var.enable_vpc ? ["apply"] : []
    content {
      subnet_ids                  = var.subnet_ids
      security_group_ids          = var.security_group_ids
      ipv6_allowed_for_dual_stack = true
    }
  }

  dynamic "file_system_config" {
    for_each = var.enable_filesystem ? ["apply"] : []

    content {
      arn              = var.access_point_arn
      local_mount_path = "/mnt/efs"
    }
  }
}

resource "aws_lambda_function" "artisan" {
  filename         = var.filename
  source_code_hash = filesha256(var.filename)
  handler          = "artisan"
  runtime          = var.lambda_runtime
  function_name    = "${local.app_name}-artisan"
  memory_size      = var.lambda_memory_size
  timeout          = 720
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = [var.php_lambda_layer_arn]

  environment {
    variables = merge(
      jsondecode(file(var.environment_variables_json_file)),
      {
        BREF_RUNTIME         = "Bref\\ConsoleRuntime\\Main"
        LOG_CHANNEL          = "stderr"
        LOG_STDERR_FORMATTER = "Bref\\Monolog\\CloudWatchFormatter"
        DYNAMODB_CACHE_TABLE = aws_dynamodb_table.cache.name
        SQS_PREFIX           = aws_sqs_queue.jobs.url
        SQS_QUEUE            = aws_sqs_queue.jobs.url
      }
    )
  }

  dynamic "vpc_config" {
    for_each = var.enable_vpc ? ["apply"] : []

    content {
      subnet_ids                  = var.subnet_ids
      security_group_ids          = var.security_group_ids
      ipv6_allowed_for_dual_stack = true
    }
  }

  dynamic "file_system_config" {
    for_each = var.enable_filesystem ? ["apply"] : []

    content {
      arn              = var.access_point_arn
      local_mount_path = "/mnt/efs"
    }
  }
}

resource "aws_lambda_function" "jobs_worker" {
  filename         = var.filename
  source_code_hash = filesha256(var.filename)
  handler          = "Bref\\LaravelBridge\\Queue\\QueueHandler"
  runtime          = var.lambda_runtime
  function_name    = "${local.app_name}-jobs-worker"
  memory_size      = var.lambda_memory_size
  timeout          = 60
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = [var.php_lambda_layer_arn]

  environment {
    variables = merge(
      jsondecode(file(var.environment_variables_json_file)),
      {
        BREF_RUNTIME         = "Bref\\FunctionRuntime\\Main"
        LOG_CHANNEL          = "stderr"
        LOG_STDERR_FORMATTER = "Bref\\Monolog\\CloudWatchFormatter"
        DYNAMODB_CACHE_TABLE = aws_dynamodb_table.cache.name
        SQS_PREFIX           = aws_sqs_queue.jobs.url
        SQS_QUEUE            = aws_sqs_queue.jobs.url
      }
    )
  }

  dynamic "vpc_config" {
    for_each = var.enable_vpc ? ["apply"] : []

    content {
      subnet_ids                  = var.subnet_ids
      security_group_ids          = var.security_group_ids
      ipv6_allowed_for_dual_stack = true
    }
  }

  dynamic "file_system_config" {
    for_each = var.enable_filesystem ? ["apply"] : []

    content {
      arn              = var.access_point_arn
      local_mount_path = "/mnt/efs"
    }
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
  event_source_arn                   = aws_sqs_queue.jobs.arn
  function_name                      = aws_lambda_function.jobs_worker.function_name
  enabled                            = true
  bisect_batch_on_function_error     = false
  function_response_types = [
    "ReportBatchItemFailures"
  ]
}
