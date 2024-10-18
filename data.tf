# caller identity data source
data "aws_caller_identity" "current" {}

# region data source
data "aws_region" "current" {}

# partition data source
data "aws_partition" "current" {}

data "aws_s3_bucket" "aws_bucket" {
  bucket = var.aws_bucket
}
