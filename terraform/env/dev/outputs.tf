# Informações do s3
output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = module.s3.bucket_arn
}

# Informações do ECR
output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = module.ecr.api_repository_url
}

output "ecr_api_repository_name" {
  description = "Nome do repositório ECR"
  value       = module.ecr.api_repository_name
}

# Informações das tabelas de certificados
output "certificates_table_name" {
  description = "Nome da tabela de certificados"
  value       = module.certificates_table.table_name
}

output "certificates_table_arn" {
  description = "ARN da tabela de certificados"
  value       = module.certificates_table.table_arn
}

# Informações das tabelas de pedidos
output "orders_table_name" {
  description = "Nome da tabela de pedidos"
  value       = module.orders_table.table_name
}

output "orders_table_arn" {
  description = "ARN da tabela de pedidos"
  value       = module.orders_table.table_arn
}

# Informações das tabelas de participantes
output "participants_table_name" {
  description = "Nome da tabela de participantes"
  value       = module.participants_table.table_name
}

output "participants_table_arn" {
  description = "ARN da tabela de participantes"
  value       = module.participants_table.table_arn
}

# Informações das tabelas de produtos
output "products_table_name" {
  description = "Nome da tabela de produtos"
  value       = module.products_table.table_name
}

output "products_table_arn" {
  description = "ARN da tabela de produtos"
  value       = module.products_table.table_arn
}

# Informações do SQS
output "sqs_queue_url" {
  description = "URL da fila SQS principal"
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "ARN da fila SQS principal"
  value       = module.sqs.queue_arn
}

output "sqs_dlq_url" {
  description = "URL da Dead Letter Queue (builder)"
  value       = module.sqs.builder_dlq_url
}
