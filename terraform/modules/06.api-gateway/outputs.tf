# Outputs do módulo API Gateway

output "api_id" {
  description = "ID do API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_arn" {
  description = "ARN do API Gateway"
  value       = aws_api_gateway_rest_api.api.arn
}

output "api_url" {
  description = "URL base do API Gateway"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
}

output "api_endpoint_create_certificate" {
  description = "URL completa do endpoint para criar certificado"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/api/v1/certificate/create"
}

output "stage_name" {
  description = "Nome do stage do API Gateway"
  value       = aws_api_gateway_stage.api_stage.stage_name
}

# Outputs da API Key
output "api_key_id" {
  description = "ID da API Key"
  value       = aws_api_gateway_api_key.main_api_key.id
}

output "api_key_value" {
  description = "Valor da API Key (sensível)"
  value       = aws_api_gateway_api_key.main_api_key.value
  sensitive   = true
}

output "usage_plan_id" {
  description = "ID do Usage Plan"
  value       = aws_api_gateway_usage_plan.main_usage_plan.id
}

output "api_endpoint_fetch_certificate" {
  description = "URL completa do endpoint para buscar certificados"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/api/v1/certificate/fetch"
}

output "api_endpoint_download_certificate" {
  description = "URL base do endpoint para download de certificados"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/api/v1/certificate/download"
}

# Data source para obter a região atual
data "aws_region" "current" {}
