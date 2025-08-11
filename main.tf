#
# CloudWatch
#
resource "aws_cloudwatch_log_group" "web_log_group" {
  name              = "/aws/lambda/${local.app_name}-web"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "artisan_log_group" {
  name              = "/aws/lambda/${local.app_name}-artisan"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "jobs_worker_log_group" {
  name              = "/aws/lambda/${local.app_name}-jobs-worker"
  retention_in_days = 1
}

resource "aws_cloudwatch_event_rule" "artisan_events_rule_schedule" {
  name                = "${local.app_name}-artisan-schedule-runner"
  schedule_expression = "rate(1 day)"
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "artisan_schedule" {
  target_id = "artisan-schedule"
  rule      = aws_cloudwatch_event_rule.artisan_events_rule_schedule.name
  arn       = aws_lambda_function.artisan_lambda_function.arn
  input     = "\"schedule:run\""
}

#
# IAM
#
resource "aws_iam_role" "lambda_execution" {
  name = "${local.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_execution" {
  name = "${local.app_name}-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:TagResource"
        ]
        Resource = [
          join(":", [
            "arn",
            data.aws_partition.current.id,
            "logs",
            data.aws_region.current.name,
            data.aws_caller_identity.current.account_id,
            "log-group",
            "/aws/lambda/${local.app_name}-*",
            "*"
          ]),
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          join(":", [
            "arn",
            data.aws_partition.current.id,
            "logs",
            data.aws_region.current.name,
            data.aws_caller_identity.current.account_id,
            "log-group",
            "/aws/lambda/${local.app_name}-*",
            "*",
            "*"
          ]),
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${data.aws_s3_bucket.aws_bucket.arn}/*"
        Effect   = "Allow"
      },
      {
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.cache_table.arn
        Effect   = "Allow"
      },
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.jobs_queue.arn
        Effect   = "Allow"
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.jobs_queue.arn
        Effect   = "Allow"
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_execution.arn
}

#
# Lambda
#
resource "aws_lambda_function" "web_lambda_function" {
  filename         = var.filename
  source_code_hash = filesha256(var.filename)
  handler          = "Bref\\LaravelBridge\\Http\\OctaneHandler"
  runtime          = var.lambda_runtime
  function_name    = "${local.app_name}-web"
  memory_size      = 1024
  timeout          = 28
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = [var.php_lambda_layer_arn]

  environment {
    variables = merge(local.lambda_function_environment_variables, {
      BREF_LOOP_MAX                    = "250"
      OCTANE_PERSIST_DATABASE_SESSIONS = "1"
    })
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

resource "aws_lambda_function" "artisan_lambda_function" {
  filename         = var.filename
  source_code_hash = filesha256(var.filename)
  handler          = "artisan"
  runtime          = var.lambda_runtime
  function_name    = "${local.app_name}-artisan"
  memory_size      = 1024
  timeout          = 720
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers = [
    var.php_lambda_layer_arn,
    var.console_lambda_layer_arn
  ]

  environment {
    variables = local.lambda_function_environment_variables
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

resource "aws_lambda_function" "jobs_worker_lambda_function" {
  filename         = var.filename
  source_code_hash = filesha256(var.filename)
  handler          = "Bref\\LaravelBridge\\Queue\\QueueHandler"
  runtime          = var.lambda_runtime
  function_name    = "${local.app_name}-jobs-worker"
  memory_size      = 1024
  timeout          = 60
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_execution.arn
  layers           = [var.php_lambda_layer_arn]

  environment {
    variables = local.lambda_function_environment_variables
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

resource "aws_lambda_permission" "artisan_lambda_permission_events_rule_schedule" {
  function_name = aws_lambda_function.artisan_lambda_function.function_name
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.artisan_events_rule_schedule.arn
}

resource "aws_lambda_event_source_mapping" "jobs_worker_event_source_mapping_sqs_jobs_queue" {
  batch_size                         = 1
  maximum_batching_window_in_seconds = 0
  event_source_arn                   = aws_sqs_queue.jobs_queue.arn
  function_name                      = aws_lambda_function.jobs_worker_lambda_function.function_name
  enabled                            = true
  bisect_batch_on_function_error     = false
  function_response_types = [
    "ReportBatchItemFailures"
  ]
}

#
# SQS
#
resource "random_string" "random" {
  length  = 6
  special = false
}

resource "aws_sqs_queue" "jobs_queue" {
  name = "${local.app_name}-jobs-${random_string.random.result}"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.jobs_dlq.arn
    maxReceiveCount     = 3
  })
  visibility_timeout_seconds = 360
}

resource "aws_sqs_queue" "jobs_dlq" {
  message_retention_seconds = 1209600
  name                      = "${local.app_name}-jobs-dlq-${random_string.random.result}"
}

#
# DynamoDB
#
resource "aws_dynamodb_table" "cache_table" {
  name         = "${local.app_name}-cache-table-${random_string.random.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

#
# API Gateway
#
resource "aws_apigatewayv2_api" "http_api" {
  name                         = local.app_name
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
  ip_address_type              = "dualstack"
}

resource "aws_apigatewayv2_stage" "http_api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = 500
    throttling_rate_limit    = 1000
  }
}

resource "aws_apigatewayv2_domain_name" "custom_domain" {
  domain_name = var.custom_domain_name

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "custom_domain_mapping" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.custom_domain.id
  stage       = aws_apigatewayv2_stage.http_api_stage.id
}

resource "aws_lambda_permission" "web_lambda_permission_http_api" {
  function_name = aws_lambda_function.web_lambda_function.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

resource "aws_apigatewayv2_integration" "http_api_integration_web" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.web_lambda_function.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "http_api_route_default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = join("/", ["integrations", aws_apigatewayv2_integration.http_api_integration_web.id])
}
