# Variáveis para configuração do Terraform

# Região AWS onde os recursos serão criados
variable "aws_region" {
  description = "Região AWS para deploy dos recursos"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "ID da conta AWS onde os recursos serão criados"
  type        = string
}

# Github

variable "github_org" {
  description = "Organização do GitHub"
  type        = string
  default     = "PythonFloripa"
}

variable "github_repo" {
  description = "Repositório do GitHub"
  type        = string
  default     = "certified-builder-infra-py"
}

variable "github_actions_role_arn" {
  description = "ARN da role IAM para GitHub Actions"
  type        = string
}

# Ambiente de deploy (dev ou live)
variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "live"], var.environment)
    error_message = "O ambiente deve ser: dev ou live."
  }
}

# Nome do projeto
variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "tech-floripa-certificates"
}

# Configuração do DynamoDB - Modo de Baixo Custo
# Todas as tabelas usam PAY_PER_REQUEST por padrão (paga apenas pelo que usar)
