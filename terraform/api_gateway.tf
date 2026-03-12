resource "aws_apigatewayv2_api" "http_api" {
  name                         = local.app_name
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
  ip_address_type              = "dualstack"
}

resource "aws_apigatewayv2_stage" "http_api" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = var.api_gateway_throttle_burst_limit
    throttling_rate_limit    = var.api_gateway_throttle_rate_limit
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

resource "aws_apigatewayv2_api_mapping" "custom_domain" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.custom_domain.id
  stage       = aws_apigatewayv2_stage.http_api.id
}

resource "aws_lambda_permission" "web_http_api" {
  function_name = aws_lambda_function.web.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

resource "aws_apigatewayv2_integration" "web" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.web.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = join("/", ["integrations", aws_apigatewayv2_integration.web.id])
}
