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

resource "aws_iam_policy" "lambda_execution" {
  name = "${local.app_name}-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
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
            data.aws_region.current.region,
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
            data.aws_region.current.region,
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
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.jobs.arn
        Effect   = "Allow"
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.jobs.arn
        Effect   = "Allow"
      },
      ], var.enable_vpc ? [{
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Effect   = "Allow"
    }] : [])
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_execution.arn
}
