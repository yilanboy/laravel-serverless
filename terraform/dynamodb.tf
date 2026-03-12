resource "aws_dynamodb_table" "cache" {
  name         = "${local.app_name}-cache-table-${random_string.resource_suffix.result}"
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
