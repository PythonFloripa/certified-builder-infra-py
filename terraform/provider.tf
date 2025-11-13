provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = "global-tf-state-${var.environment}"
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  }
}
