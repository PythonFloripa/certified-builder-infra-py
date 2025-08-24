# Variáveis para o módulo SQS

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
}

variable "queue_name_builder" {
  description = "Nome da fila de build"
  type        = string
  default     = "builder-queue"
}

variable "queue_name_builder_dlq" {
  description = "Nome da fila de build DLQ"
  type        = string
  default     = "builder-queue-dlq"
}


variable "queue_name_notification" {
  description = "Nome da fila de notificação"
  type        = string
  default     = "notification-queue"
}

variable "queue_name_notification_dlq" {
  description = "Nome da fila de notificação DLQ"
  type        = string
  default     = "notification-queue-dlq"
}
