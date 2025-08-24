# Módulo S3 para Certified Builder API
# Responsável por criar o bucket S3 para armazenar os arquivos do projeto

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  force_destroy = true # Deleta o bucket mesmo que contenha objetos
  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Region      = var.region
    Environment = var.environment
    Project     = var.project_name
  }
}

# Configuração de ciclo de vida para o bucket S3
# Define regras para expiração automática de objetos baseado em prefixos e tempo
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count  = length(var.lifecycle_rule) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rule
    content {
      id     = rule.value.id
      status = rule.value.status

      # Filtro por prefixo (ex: "certificates/" para certificados)
      dynamic "filter" {
        for_each = rule.value.prefix != null ? [rule.value.prefix] : []
        content {
          prefix = filter.value
        }
      }

      # Regra de expiração - remove objetos após X dias
      expiration {
        days = rule.value.expiration
      }
    }
  }

  depends_on = [aws_s3_bucket.bucket]
}
