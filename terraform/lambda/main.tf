# Módulo Lambda para Certified Builder API
# Responsável por criar a função Lambda que executa a aplicação containerizada

# IAM Role para a função Lambda para acessar o ECR, SQS e S3
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Policy básica para execução do Lambda 
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Policy personalizada para acessar DynamoDB, SQS e ECR
resource "aws_iam_role_policy" "lambda_custom_policy" {
  name = "${var.project_name}-lambda-policy-${var.environment}"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          var.builder_queue_arn,
          var.notification_queue_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Resource = [
          var.ecr_repository_arn,
          "${var.ecr_repository_arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_builder_execution_role" {
  name = "${var.project_name}-lambda-builder-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-ecr-builder-execution-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Policy básica para execução do Lambda Builder
resource "aws_iam_role_policy_attachment" "lambda_builder_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_builder_execution_role.name
}

# Policy para acessar ECR
resource "aws_iam_role_policy_attachment" "lambda_builder_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.lambda_builder_execution_role.name
}

resource "aws_iam_role_policy" "lambda_builder_custom_policy" {
  name = "${var.project_name}-lambda-builder-policy-${var.environment}"
  role = aws_iam_role.lambda_builder_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [
          var.ecr_builder_repository_arn,
          "${var.ecr_builder_repository_arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = [
          var.builder_queue_arn,
          var.notification_queue_arn
        ]
      },
    ]
  })
}

# Data source para detectar mudanças na imagem ECR
data "aws_ecr_image" "api_lambda_image" {
  repository_name = split("/", var.ecr_api_repository_url)[1] # Extrai o nome do repositório da URL
  image_tag       = var.image_tag
}

# Função Lambda
resource "aws_lambda_function" "api_function" {
  function_name = "${var.project_name}-api-${var.environment}"
  role         = aws_iam_role.lambda_execution_role.arn
  
  # Configuração da imagem Docker usando digest para forçar atualização
  package_type = "Image"
  image_uri    = "${var.ecr_api_repository_url}@${data.aws_ecr_image.api_lambda_image.image_digest}"
  
  # Configurações de performance e timeout
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  
  # Variáveis de ambiente baseadas no env.example
  environment {
    variables = {
      REGION                 = var.aws_region
      BUILDER_QUEUE_URL      = var.builder_queue_url
      ENVIRONMENT            = var.environment
      PROJECT_NAME           = var.project_name
      URL_SERVICE_TECH       = var.url_service_tech
      PREFIX_API_VERSION     = var.prefix_api_version
    }
  }

  # Configuração para atualizar quando a imagem ECR mudar
  lifecycle {
    create_before_destroy = true
    # Remove ignore_changes para permitir detecção automática de mudanças
  }

  tags = {
    Name        = "${var.project_name}-api-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# CloudWatch Log Group para a função Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.api_function.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-lambda-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Data source para detectar mudanças na imagem ECR do builder
data "aws_ecr_image" "builder_lambda_image" {
  repository_name = split("/", var.ecr_builder_repository_url)[1] # Extrai o nome do repositório da URL
  image_tag       = var.image_tag
}

resource "aws_lambda_function" "builder_funcition" {
  function_name = "${var.project_name}-builder-${var.environment}"
  role         = aws_iam_role.lambda_builder_execution_role.arn
  package_type = "Image"
  # Configuração da imagem Docker usando digest para forçar atualização
  image_uri    = "${var.ecr_builder_repository_url}@${data.aws_ecr_image.builder_lambda_image.image_digest}"
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      REGION                 = var.aws_region
      QUEUE_URL              = var.notification_queue_url
      BUCKET_NAME            = var.s3_bucket_name
    }
  }

  # Configuração para atualizar quando a imagem ECR mudar
  lifecycle {
    create_before_destroy = true
    # Remove ignore_changes para permitir detecção automática de mudanças
  }

  tags = {
    Name        = "${var.project_name}-builder-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "builder_logs" {
  name              = "/aws/lambda/${aws_lambda_function.builder_funcition.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-builder-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Event Source Mapping - Conecta a fila SQS builder com a função Lambda builder
# Quando uma mensagem chegar na fila, a Lambda será executada automaticamente
resource "aws_lambda_event_source_mapping" "builder_sqs_trigger" {
  event_source_arn = var.builder_queue_arn
  function_name    = aws_lambda_function.builder_funcition.arn
  
  # Configurações do processamento em lote
  batch_size                         = 1    # Processa 1 mensagem por vez
  maximum_batching_window_in_seconds = 5    # Aguarda até 5 segundos para formar um lote
  scaling_config {
    maximum_concurrency = 3
  }
  # Configurações de retry e erro
  function_response_types = ["ReportBatchItemFailures"]
  
  tags = {
    Name        = "${var.project_name}-builder-sqs-trigger-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Role para a função Lambda de notificação
resource "aws_iam_role" "lambda_notification_execution_role" {
  name = "${var.project_name}-lambda-notification-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-notification-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Policy básica para execução do Lambda de notificação
resource "aws_iam_role_policy_attachment" "lambda_notification_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_notification_execution_role.name
}

# Policy personalizada para a Lambda de notificação acessar DynamoDB, S3 e SQS
resource "aws_iam_role_policy" "lambda_notification_custom_policy" {
  name = "${var.project_name}-lambda-notification-policy-${var.environment}"
  role = aws_iam_role.lambda_notification_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          var.builder_queue_arn,
          var.notification_queue_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [
          var.ecr_notification_repository_arn,
          "${var.ecr_notification_repository_arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Data source para detectar mudanças na imagem ECR de notificação
data "aws_ecr_image" "notification_lambda_image" {
  repository_name = split("/", var.ecr_notification_repository_url)[1] # Extrai o nome do repositório da URL
  image_tag       = var.image_tag
}

# Função Lambda para processamento de notificações
resource "aws_lambda_function" "notification_function" {
  function_name = "${var.project_name}-notification-${var.environment}"
  role         = aws_iam_role.lambda_notification_execution_role.arn
  package_type = "Image"
  
  # Configuração da imagem Docker usando digest para forçar atualização
  image_uri    = "${var.ecr_notification_repository_url}@${data.aws_ecr_image.notification_lambda_image.image_digest}"
  
  # Configurações de performance e timeout
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  # Variáveis de ambiente para a Lambda de notificação
  environment {
    variables = {
      REGION           = var.aws_region
      S3_BUCKET_NAME   = var.s3_bucket_name
      ENVIRONMENT      = var.environment
      PROJECT_NAME     = var.project_name
      URL_SERVICE_TECH = var.url_service_tech
    }
  }

  # Configuração para atualizar quando a imagem ECR mudar
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-notification-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# CloudWatch Log Group para a função Lambda de notificação
resource "aws_cloudwatch_log_group" "notification_logs" {
  name              = "/aws/lambda/${aws_lambda_function.notification_function.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-notification-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Event Source Mapping - Conecta a fila SQS de notificação com a função Lambda de notificação
# Quando uma mensagem chegar na fila de notificação, a Lambda será executada automaticamente
resource "aws_lambda_event_source_mapping" "notification_sqs_trigger" {
  event_source_arn = var.notification_queue_arn
  function_name    = aws_lambda_function.notification_function.arn
  
  # Configurações do processamento em lote
  batch_size                         = 1    # Processa 1 mensagem por vez
  maximum_batching_window_in_seconds = 5    # Aguarda até 5 segundos para formar um lote
  scaling_config {
    maximum_concurrency = 2  # Limite menor para notificações
  }
  
  # Configurações de retry e erro
  function_response_types = ["ReportBatchItemFailures"]
  
  tags = {
    Name        = "${var.project_name}-notification-sqs-trigger-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}