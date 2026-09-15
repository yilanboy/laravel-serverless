data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_s3_bucket" "main" {
  bucket = var.aws_bucket
}

data "aws_ssm_parameter" "env" {
  count           = var.ssm_parameter_name != "" ? 1 : 0
  name            = var.ssm_parameter_name
  with_decryption = true
}
