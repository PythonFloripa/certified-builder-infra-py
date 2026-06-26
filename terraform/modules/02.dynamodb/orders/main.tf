# Módulo para tabela de Pedidos - Configuração de Baixo Custo
# Baseado no modelo: src/domain/entity/order.py

resource "aws_dynamodb_table" "orders" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # Modo mais econômico - paga apenas pelo que usar
  hash_key     = "order_id"

  # Definição dos atributos baseados no modelo Order
  attribute {
    name = "order_id"
    type = "N" # Number para order_id
  }

  attribute {
    name = "participant_email"
    type = "S"
  }

  attribute {
    name = "product_id"
    type = "N"
  }

  attribute {
    name = "order_year_month"
    type = "S"
  }

  attribute {
    name = "order_date_order_id"
    type = "S"
  }

  global_secondary_index {
    name            = "orders_by_email_idx"
    hash_key        = "participant_email"
    range_key       = "order_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "orders_by_product_idx"
    hash_key        = "product_id"
    range_key       = "order_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "orders_by_month_idx"
    hash_key        = "order_year_month"
    range_key       = "order_date_order_id"
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
    Entity      = "Order"
    CostCenter  = "low-cost"
  }
}
