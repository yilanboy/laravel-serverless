provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Service     = var.tag_service
      Environment = var.tag_environment
      Owner       = var.tag_owner
    }
  }
}
