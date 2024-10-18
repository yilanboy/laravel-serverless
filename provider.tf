provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Service     = var.tag_service
      Environment = var.tag_environment
      Owner       = var.tag_owner
    }
  }
}
