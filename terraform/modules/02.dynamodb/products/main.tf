# Módulo para tabela de Produtos - Configuração de Baixo Custo
# Baseado no modelo: src/domain/entity/product.py

resource "aws_dynamodb_table" "products" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # Modo mais econômico - paga apenas pelo que usar
  hash_key     = "product_id"

  # Definição dos atributos baseados no modelo Product
  attribute {
    name = "product_id"
    type = "N" # Number para product_id
  }

  attribute {
    name = "product_name"
    type = "S"
  }

  attribute {
    name = "has_certificate_logo_flag"
    type = "N"
  }

  attribute {
    name = "has_certificate_background_flag"
    type = "N"
  }

  global_secondary_index {
    name            = "products_by_name_idx"
    hash_key        = "product_name"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "products_by_has_logo_idx"
    hash_key        = "has_certificate_logo_flag"
    range_key       = "product_name"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "products_by_has_background_idx"
    hash_key        = "has_certificate_background_flag"
    range_key       = "product_name"
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
    Entity      = "Product"
    CostCenter  = "low-cost"
  }
}
