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

# ============================================================================
# DynamoDB Outputs
# ============================================================================

output "dynamodb_certificates_table_name" {
  description = "Nome da tabela de certificados"
  value       = module.dynamodb_certificates.table_name
}

output "dynamodb_certificates_table_arn" {
  description = "ARN da tabela de certificados"
  value       = module.dynamodb_certificates.table_arn
}

output "dynamodb_orders_table_name" {
  description = "Nome da tabela de pedidos"
  value       = module.dynamodb_orders.table_name
}

output "dynamodb_orders_table_arn" {
  description = "ARN da tabela de pedidos"
  value       = module.dynamodb_orders.table_arn
}

output "dynamodb_participants_table_name" {
  description = "Nome da tabela de participantes"
  value       = module.dynamodb_participants.table_name
}

output "dynamodb_participants_table_arn" {
  description = "ARN da tabela de participantes"
  value       = module.dynamodb_participants.table_arn
}

output "dynamodb_products_table_name" {
  description = "Nome da tabela de produtos"
  value       = module.dynamodb_products.table_name
}

output "dynamodb_products_table_arn" {
  description = "ARN da tabela de produtos"
  value       = module.dynamodb_products.table_arn
}
