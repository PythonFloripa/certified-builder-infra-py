# Configuração principal do Terraform para Certified Builder API PY
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configuração do provider AWS
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "certified-builder-api"
      ManagedBy = "terraform"
    }
  }
}

# Módulo para tabela de Certificados
module "certificates_table" {
  source = "./dynamodb/certificates"

  table_name   = "${var.project_name}-certificates-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

# Módulo para tabela de Pedidos
module "orders_table" {
  source = "./dynamodb/orders"

  table_name   = "${var.project_name}-orders-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

# Módulo para tabela de Participantes
module "participants_table" {
  source = "./dynamodb/participants"

  table_name   = "${var.project_name}-participants-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

# Módulo para tabela de Produtos 
module "products_table" {
  source = "./dynamodb/products"

  table_name   = "${var.project_name}-products-${var.environment}"
  environment  = var.environment
  project_name = var.project_name
}

# Módulo SQS para filas de mensageria
module "sqs" {
  source = "./sqs"

  project_name = var.project_name
  environment  = var.environment
}

# Módulo ECR para hospedar imagens Docker
module "ecr" {
  source = "./ecr"

  api_repository_name = "${var.project_name}-api-${var.environment}"
  builder_repository_name = "${var.project_name}-builder-${var.environment}"
  project_name    = var.project_name
}

# Módulo S3 para armazenar arquivos
module "s3" {
  source = "./bucket_s3"

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

# Módulo Lambda para execução da aplicação
module "lambda" {
  source = "./lambda"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  ecr_api_repository_name = module.ecr.api_repository_name
  ecr_api_repository_url  = module.ecr.api_repository_url
  ecr_builder_repository_name = module.ecr.builder_repository_name
  ecr_builder_repository_url = module.ecr.builder_repository_url
  ecr_builder_repository_arn = module.ecr.builder_repository_arn
  image_tag           = var.lambda_image_tag
  lambda_timeout      = var.lambda_timeout
  lambda_memory_size  = var.lambda_memory_size
  log_retention_days  = var.log_retention_days

  # Variáveis de ambiente da aplicação
  url_service_tech   = var.url_service_tech
  prefix_api_version = var.prefix_api_version

  # Variáveis específicas da fila builder
  builder_queue_url      = module.sqs.builder_queue_url
  builder_queue_arn      = module.sqs.builder_queue_arn
  notification_queue_arn = module.sqs.notification_queue_arn
  notification_queue_url = module.sqs.notification_queue_url

  # ARNs para políticas IAM
  dynamodb_table_arns = [
    module.certificates_table.table_arn,
    module.orders_table.table_arn,
    module.participants_table.table_arn,
    module.products_table.table_arn
  ]
  ecr_repository_arn = module.ecr.api_repository_arn
  s3_bucket_arn      = module.s3.bucket_arn
  s3_bucket_name     = module.s3.bucket_name

}

# Módulo API Gateway REST para exposição da API
module "api_gateway" {
  source = "./api-gateway"

  project_name         = var.project_name
  environment          = var.environment
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  throttle_rate_limit  = var.api_throttle_rate_limit
  throttle_burst_limit = var.api_throttle_burst_limit
}
