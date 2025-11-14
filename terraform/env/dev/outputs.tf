# ============================================================================
# ECR Outputs
# ============================================================================

output "ecr_api_repository_url" {
  description = "URL of the API ECR repository"
  value       = module.ecr.api_repository_url
}

output "ecr_builder_repository_url" {
  description = "URL of the Builder ECR repository"
  value       = module.ecr.builder_repository_url
}

output "ecr_notification_repository_url" {
  description = "URL of the Notification ECR repository"
  value       = module.ecr.notification_repository_url
}

output "ecr_api_repository_arn" {
  description = "ARN of the API ECR repository"
  value       = module.ecr.api_repository_arn
}

output "ecr_builder_repository_arn" {
  description = "ARN of the Builder ECR repository"
  value       = module.ecr.builder_repository_arn
}

output "ecr_notification_repository_arn" {
  description = "ARN of the Notification ECR repository"
  value       = module.ecr.notification_repository_arn
}
