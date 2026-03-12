data "aws_s3_bucket" "main" {
  bucket = var.aws_bucket
}

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

data "aws_iam_policy" "aws_lambda_vpc_access_execution_role" {
  arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

locals {
  lambda_function_log_group_arn_wildcard = join(":", [
    "arn",
    data.aws_partition.current.id,
    "logs",
    data.aws_region.current.region,
    data.aws_caller_identity.current.account_id,
    "log-group",
    "/aws/lambda/${local.app_name}*",
    "*"
  ])
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
          local.lambda_function_log_group_arn_wildcard
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          "${local.lambda_function_log_group_arn_wildcard}:*"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${data.aws_s3_bucket.main.arn}/*"
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
        Resource = aws_dynamodb_table.cache.arn
        Effect   = "Allow"
      },
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ChangeMessageVisibility",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.jobs.arn
        Effect   = "Allow"
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_execution.arn
}

resource "aws_iam_role_policy_attachment" "aws_lambda_vpc_access_execution" {
  count = var.enable_vpc ? 1 : 0

  role       = aws_iam_role.lambda_execution.name
  policy_arn = data.aws_iam_policy.aws_lambda_vpc_access_execution_role.arn
}
