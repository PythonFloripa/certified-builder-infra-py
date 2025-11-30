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
  description = "Regras de ciclo de vida dos objetos S3"
  value       = length(aws_s3_bucket_lifecycle_configuration.certificates_bucket_lifecycle_config) > 0 ? aws_s3_bucket_lifecycle_configuration.bucket_lifecycle[0] : null
}
