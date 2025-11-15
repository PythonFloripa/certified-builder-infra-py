# ============================================================================
# ECR Module - Container Registries for Dev Environment
# ============================================================================

module "ecr" {
  source = "../../modules/01.ecr"

  project_name                 = var.project_name
  api_repository_name          = "${var.project_name}-api-${var.environment}"
  builder_repository_name      = "${var.project_name}-builder-${var.environment}"
  notification_repository_name = "${var.project_name}-notification-${var.environment}"
}


