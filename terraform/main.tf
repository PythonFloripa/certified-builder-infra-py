terraform {
  required_version = ">= 1.13.5, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.22.1"
    }
  }
  backend "s3" {
    bucket = "tech-floripa-certificates-dev-tf-state"
    key    = "shared/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "shared"
      ManagedBy   = "terraform"
    }
  }
}

resource "aws_s3_bucket" "tech_floripa_certificates_dev_tf_state" {
  bucket = "tech-floripa-certificates-dev-tf-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "tech_floripa_certificates_dev_tf_state_policy" {
  bucket = aws_s3_bucket.tech_floripa_certificates_dev_tf_state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGitHubActionsRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:role/github-actions-assume-role"
        }
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.tech_floripa_certificates_dev_tf_state.arn,
          "${aws_s3_bucket.tech_floripa_certificates_dev_tf_state.arn}/*"
        ]
      }
    ]
  })
}


