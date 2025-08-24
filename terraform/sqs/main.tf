# Módulo SQS para Certified Builder API
# Responsável por criar duas filas SQS para processamento assíncrono

# Fila principal para construção de certificados
resource "aws_sqs_queue" "builder_queue" {
  name                       = "${var.project_name}-${var.queue_name_builder}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 86400  # 1 dia
  receive_wait_time_seconds  = 10     # Long polling para reduzir custos
  visibility_timeout_seconds = 60

  # Dead Letter Queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.builder_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.project_name}-${var.queue_name_builder}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Dead Letter Queue para fila de construção
resource "aws_sqs_queue" "builder_dlq" {
  name                      = "${var.project_name}-${var.queue_name_builder_dlq}"
  message_retention_seconds = 86400  # 1 dia

  tags = {
    Name        = "${var.project_name}-${var.queue_name_builder_dlq}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Fila para notificações
resource "aws_sqs_queue" "notification_queue" {
  name                       = "${var.project_name}-${var.queue_name_notification}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 86400  # 1 dia
  receive_wait_time_seconds  = 10     # Long polling para reduzir custos
  visibility_timeout_seconds = 60

  # Dead Letter Queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.project_name}-${var.queue_name_notification}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Dead Letter Queue para fila de notificação
resource "aws_sqs_queue" "notification_dlq" {
  name                      = "${var.project_name}-${var.queue_name_notification_dlq}"
  message_retention_seconds = 86400  # 1 dia

  tags = {
    Name        = "${var.project_name}-${var.queue_name_notification_dlq}"
    Environment = var.environment
    Project     = var.project_name
  }
}
