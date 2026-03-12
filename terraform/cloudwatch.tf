resource "aws_cloudwatch_log_group" "web" {
  name              = "/aws/lambda/${local.app_name}-web"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "artisan" {
  name              = "/aws/lambda/${local.app_name}-artisan"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "jobs_worker" {
  name              = "/aws/lambda/${local.app_name}-jobs-worker"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_event_rule" "artisan_schedule" {
  name                = "${local.app_name}-artisan-schedule-runner"
  schedule_expression = "rate(1 day)"
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "artisan_schedule" {
  target_id = "artisan-schedule"
  rule      = aws_cloudwatch_event_rule.artisan_schedule.name
  arn       = aws_lambda_function.artisan.arn
  input     = "\"schedule:run\""
}
