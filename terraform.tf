terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }
  }

  backend "s3" {
    bucket         = "us-west-2-terraform-state-storage"
    key            = "us-west-2-blog-serverless.tfstate"
    region         = "us-west-2"
    dynamodb_table = "us-west-2-terraform-state-locking"
  }
}
