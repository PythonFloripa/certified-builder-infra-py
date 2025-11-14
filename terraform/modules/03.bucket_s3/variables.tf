variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

# Ciclo de vida dos objetos - apagar objetos antigos após configuração de dias
variable "lifecycle_rule" {
  description = "Regras de ciclo de vida dos objetos S3"
  type = list(object({
    id         = string           # Identificador único da regra
    prefix     = optional(string) # Prefixo dos objetos afetados (ex: "certificates/")
    expiration = number           # Dias para expiração dos objetos
    status     = optional(string, "Enabled") # Status da regra (Enabled/Disabled)
  }))
  default = []
}


