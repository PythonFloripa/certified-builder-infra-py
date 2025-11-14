terraform {
  required_version = ">= 1.13.5, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.21.0, < 7.0.0"
    }
  }
    backend "s3" {
      bucket = "tech-floripa-certificates-dev-tf-state"
      key    = "shared/terraform.tfstate"
      region = "us-east-1"
    }
}

provider "aws" {
  region  = var.aws_region


  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "shared"
      ManagedBy   = "terraform"
    }
  }
}
