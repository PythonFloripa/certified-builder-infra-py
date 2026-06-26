# Módulo para tabela de Certificados - Configuração de Baixo Custo
# Baseado no modelo: src/domain/entity/certificate.py

resource "aws_dynamodb_table" "certificates" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # Modo mais econômico - paga apenas pelo que usar
  hash_key     = "order_id"

  # Definição dos atributos baseados no modelo Certificate
  attribute {
    name = "order_id"
    type = "N" # Number para order_id
  }

  attribute {
    name = "id"
    type = "S" # String para UUID
  }

  attribute {
    name = "participant_email"
    type = "S"
  }

  attribute {
    name = "participant_email_product_key"
    type = "S"
  }

  attribute {
    name = "product_id"
    type = "N"
  }

  attribute {
    name = "success_flag"
    type = "N"
  }

  global_secondary_index {
    name            = "certificate_id_idx"
    hash_key        = "id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "certificates_by_email_idx"
    hash_key        = "participant_email"
    range_key       = "order_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "certificates_by_email_product_idx"
    hash_key        = "participant_email_product_key"
    range_key       = "order_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "certificates_by_product_idx"
    hash_key        = "product_id"
    range_key       = "order_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "certificates_by_success_idx"
    hash_key        = "success_flag"
    range_key       = "order_id"
    projection_type = "ALL"
  }

  # Criptografia básica (sem custo adicional)
  server_side_encryption {
    enabled = true
  }

  # Tags para organização
  tags = {
    Name        = var.table_name
    Environment = var.environment
    Project     = var.project_name
    Entity      = "Certificate"
    CostCenter  = "low-cost"
  }
}
