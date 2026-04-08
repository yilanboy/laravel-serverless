provider "aws" {
  region = "us-east-1"
}
resource "aws_sqs_queue" "test" {
  name = "test"
}
output "url" {
  value = aws_sqs_queue.test.url
}
