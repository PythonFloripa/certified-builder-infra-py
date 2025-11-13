# Outputs do módulo SQS

# Outputs genéricos para compatibilidade (apontam para a fila builder)
output "queue_url" {
  description = "URL da fila SQS principal (builder)"
  value       = aws_sqs_queue.builder_queue.url
}

output "queue_arn" {
  description = "ARN da fila SQS principal (builder)"
  value       = aws_sqs_queue.builder_queue.arn
}

# Outputs da fila de construção (builder)
output "builder_queue_url" {
  description = "URL da fila SQS de construção"
  value       = aws_sqs_queue.builder_queue.url
}

output "builder_queue_arn" {
  description = "ARN da fila SQS de construção"
  value       = aws_sqs_queue.builder_queue.arn
}

output "builder_dlq_url" {
  description = "URL da Dead Letter Queue de construção"
  value       = aws_sqs_queue.builder_dlq.url
}

output "builder_dlq_arn" {
  description = "ARN da Dead Letter Queue de construção"
  value       = aws_sqs_queue.builder_dlq.arn
}

# Outputs da fila de notificação
output "notification_queue_url" {
  description = "URL da fila SQS de notificação"
  value       = aws_sqs_queue.notification_queue.url
}

output "notification_queue_arn" {
  description = "ARN da fila SQS de notificação"
  value       = aws_sqs_queue.notification_queue.arn
}

output "notification_dlq_url" {
  description = "URL da Dead Letter Queue de notificação"
  value       = aws_sqs_queue.notification_dlq.url
}

output "notification_dlq_arn" {
  description = "ARN da Dead Letter Queue de notificação"
  value       = aws_sqs_queue.notification_dlq.arn
}
