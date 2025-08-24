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
