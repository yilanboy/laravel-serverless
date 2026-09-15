resource "aws_dynamodb_table" "cache" {
  name         = "${var.app_name}-cache-table-${var.resource_suffix}"
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
