# Outputs do módulo ECR

output "api_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.api_repository.repository_url
}

output "api_repository_arn" {
  description = "ARN do repositório ECR"
  value       = aws_ecr_repository.api_repository.arn
}

output "api_repository_name" {
  description = "Nome do repositório ECR"
  value       = aws_ecr_repository.api_repository.name
}

output "builder_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.builder_repository.repository_url
}

output "builder_repository_name" {
  description = "Nome do repositório ECR"
  value       = aws_ecr_repository.builder_repository.name
}

output "builder_repository_arn" {
  description = "ARN do repositório ECR"
  value       = aws_ecr_repository.builder_repository.arn
}