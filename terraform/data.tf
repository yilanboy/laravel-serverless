data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_s3_bucket" "main" {
  bucket = var.aws_bucket
}
