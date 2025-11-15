# ============================================================================
# ECR Module - Container Registries
# ============================================================================

module "ecr" {
  source = "../../modules/01.ecr"

  project_name                 = var.project_name
  api_repository_name          = "${var.project_name}-api-${var.environment}"
  builder_repository_name      = "${var.project_name}-builder-${var.environment}"
  notification_repository_name = "${var.project_name}-notification-${var.environment}"
}

# ============================================================================
# DynamoDB Modules
# ============================================================================

module "dynamodb_certificates" {
  source      = "../../modules/02.dynamodb/certificates"
  project_name = var.project_name
  environment  = var.environment
  table_name   = "${var.project_name}-certificates-${var.environment}"
}

module "dynamodb_orders" {
  source      = "../../modules/02.dynamodb/orders"
  project_name = var.project_name
  environment  = var.environment
  table_name   = "${var.project_name}-orders-${var.environment}"
}

module "dynamodb_participants" {
  source      = "../../modules/02.dynamodb/participants"
  project_name = var.project_name
  environment  = var.environment
  table_name   = "${var.project_name}-participants-${var.environment}"
}

module "dynamodb_products" {
  source      = "../../modules/02.dynamodb/products"
  project_name = var.project_name
  environment  = var.environment
  table_name   = "${var.project_name}-products-${var.environment}"
}


