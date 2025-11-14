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

variable "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  type        = string
}

variable "api_key_value" {
  description = "API Key for authentication"
  type        = string
  sensitive   = true
}

variable "service_url_registration_api_solana" {
  description = "URL for Solana registration API service"
  type        = string
}

variable "service_api_key_registration_api_solana" {
  description = "API Key for Solana registration service"
  type        = string
  sensitive   = true
}

variable "tech_floripa_certificate_validate_url" {
  description = "URL for Tech Floripa certificate validation"
  type        = string
}
