# Variáveis para configuração do Terraform

# Região AWS onde os recursos serão criados
variable "aws_region" {
  description = "Região AWS para deploy dos recursos"
  type        = string
  default     = "us-east-1"
}

# Ambiente de deploy (dev, staging, prod)
variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser: dev, staging ou prod."
  }
}

# Nome do projeto
variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

# Configuração do DynamoDB - Modo de Baixo Custo
# Todas as tabelas usam PAY_PER_REQUEST por padrão (paga apenas pelo que usar)

# Variáveis para Lambda Function
variable "lambda_image_tag" {
  description = "Tag da imagem Docker para o Lambda"
  type        = string
  default     = "latest"
}

variable "lambda_timeout" {
  description = "Timeout da função Lambda em segundos"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Memória alocada para a função Lambda em MB"
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs do CloudWatch"
  type        = number
  default     = 3
}

variable "url_service_tech" {
  description = "URL do serviço Tech Floripa"
  type        = string
  default     = "https://tech.floripa.br/wp-json/custom/v1"
}

variable "prefix_api_version" {
  description = "Prefixo da versão da API"
  type        = string
  default     = "/api/v1"
}

# Variáveis para API Gateway
variable "api_throttle_rate_limit" {
  description = "Limite de taxa por segundo para throttling do API Gateway"
  type        = number
  default     = 100
}

variable "api_throttle_burst_limit" {
  description = "Limite de burst para throttling do API Gateway"
  type        = number
  default     = 200
}

variable "api_key_value" {
  description = "Valor da API Key para autenticação do API Gateway (deve ser fornecido via terraform.tfvars)"
  type        = string
  sensitive   = true
  
  validation {
    condition = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.api_key_value))
    error_message = "A API Key deve estar no formato UUID válido (ex: 8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29)."
  }
}

# Variáveis para integração com API Solana
variable "service_url_registration_api_solana" {
  description = "URL do serviço de registro da API Solana"
  type        = string
}

variable "service_api_key_registration_api_solana" {
  description = "API Key do serviço de registro da API Solana"
  type        = string
  sensitive   = true
}
