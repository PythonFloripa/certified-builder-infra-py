# Variáveis para o módulo ECR

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "api_repository_name" {
  description = "Nome do repositório ECR"
  type        = string
}

variable "builder_repository_name" {
  description = "Nome do repositório ECR"
  type        = string
}

variable "notification_repository_name" {
  description = "Nome do repositório ECR"
  type        = string
}