# Variáveis para o módulo API Gateway

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
}

variable "lambda_function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "ARN para invocar a função Lambda"
  type        = string
}

variable "throttle_rate_limit" {
  description = "Limite de taxa por segundo para throttling"
  type        = number
  default     = 100
}

variable "throttle_burst_limit" {
  description = "Limite de burst para throttling"
  type        = number
  default     = 200
}

variable "api_key_value" {
  description = "Valor da API Key para autenticação (deve ser um UUID válido)"
  type        = string
  sensitive   = true
  
  validation {
    condition = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.api_key_value))
    error_message = "A API Key deve estar no formato UUID válido (ex: 8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29)."
  }
}
