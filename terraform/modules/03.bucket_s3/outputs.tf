# Outputs do módulo S3

output "bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.certificates_bucket.id
}

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.certificates_bucket.arn
}

output "lifecycle_rule" {
  description = "Lista de regras de ciclo de vida configuradas para o bucket S3 (sempre retorna uma lista, vazia se não houver regras)"
  value       = aws_s3_bucket_lifecycle_configuration.certificates_bucket_lifecycle_config[*].rule
}
