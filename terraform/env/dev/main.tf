# S3 Bucket
module "s3" {
  source       = "../../modules/03.bucket_s3"
  bucket_name  = "${var.project_name}-${var.environment}-bucket"
  environment  = var.environment
  project_name = var.project_name
  region       = var.aws_region
  lifecycle_rule = [
    {
      id         = "lifecycle-rule"
      prefix     = "certificates/"
      expiration = 90
      status     = "Enabled"
    }
  ]
}

# ECR
module "ecr" {
  source                       = "../../modules/01.ecr"
  api_repository_name          = "${var.project_name}-api-${var.environment}"
  builder_repository_name      = "${var.project_name}-builder-${var.environment}"
  notification_repository_name = "${var.project_name}-notification-${var.environment}"
  project_name                 = var.project_name
}

# DynamoDB Tables
module "certificates_table" {
  source       = "../../modules/02.dynamodb/certificates"
  table_name   = "${var.project_name}-certificates-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

module "orders_table" {
  source       = "../../modules/02.dynamodb/orders"
  table_name   = "${var.project_name}-orders-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

module "participants_table" {
  source       = "../../modules/02.dynamodb/participants"
  table_name   = "${var.project_name}-participants-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

module "products_table" {
  source       = "../../modules/02.dynamodb/products"
  table_name   = "${var.project_name}-products-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

# SQS
module "sqs" {
  source       = "../../modules/04.sqs"
  project_name = var.project_name
  environment  = var.environment
}
