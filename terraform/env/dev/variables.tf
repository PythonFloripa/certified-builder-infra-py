variable "aws_region" {
  description = "AWS region for dev environment"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "tech-floripa-certificates"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
