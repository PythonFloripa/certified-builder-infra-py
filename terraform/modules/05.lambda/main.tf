data "archive_file" "lambda_bootstrap" {
  type        = "zip"
  source_file = "${path.module}/bootstrap/lambda_function.py"
  output_path = "${path.module}/bootstrap/lambda-bootstrap.zip"
}

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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

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
          "s3:GetObject",
          "s3:GetObjectVersion",
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

resource "aws_lambda_function" "api_function" {
  function_name    = "${var.project_name}-api-${var.environment}"
  role             = aws_iam_role.lambda_execution_role.arn
  package_type     = "Zip"
  runtime          = "python3.13"
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_bootstrap.output_path
  source_code_hash = data.archive_file.lambda_bootstrap.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      REGION             = var.aws_region
      BUILDER_QUEUE_URL  = var.builder_queue_url
      S3_BUCKET_NAME     = var.s3_bucket_name
      ENVIRONMENT        = var.environment
      PROJECT_NAME       = var.project_name
      URL_SERVICE_TECH   = var.url_service_tech
      PREFIX_API_VERSION = var.prefix_api_version
    }
  }

  tags = {
    Name        = "${var.project_name}-api-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.api_function.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-lambda-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
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
    Name        = "${var.project_name}-lambda-builder-role-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_builder_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
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
      }
    ]
  })
}

resource "aws_lambda_function" "builder_function" {
  function_name    = "${var.project_name}-builder-${var.environment}"
  role             = aws_iam_role.lambda_builder_execution_role.arn
  package_type     = "Zip"
  runtime          = "python3.13"
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_bootstrap.output_path
  source_code_hash = data.archive_file.lambda_bootstrap.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      REGION                                  = var.aws_region
      QUEUE_URL                               = var.notification_queue_url
      BUCKET_NAME                             = var.s3_bucket_name
      SERVICE_URL_REGISTRATION_API_SOLANA     = var.service_url_registration_api_solana
      SERVICE_API_KEY_REGISTRATION_API_SOLANA = var.service_api_key_registration_api_solana
      TECH_FLORIPA_CERTIFICATE_VALIDATE_URL   = var.tech_floripa_certificate_validate_url
      TECH_FLORIPA_LOGO_URL                   = var.tech_floripa_logo_url
    }
  }

  tags = {
    Name        = "${var.project_name}-builder-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "builder_logs" {
  name              = "/aws/lambda/${aws_lambda_function.builder_function.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-builder-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_lambda_event_source_mapping" "builder_sqs_trigger" {
  event_source_arn                   = var.builder_queue_arn
  function_name                      = aws_lambda_function.builder_function.arn
  batch_size                         = 1
  maximum_batching_window_in_seconds = 10

  scaling_config {
    maximum_concurrency = 2
  }

  function_response_types = ["ReportBatchItemFailures"]

  tags = {
    Name        = "${var.project_name}-builder-sqs-trigger-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

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

resource "aws_iam_role_policy_attachment" "lambda_notification_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_notification_execution_role.name
}

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

resource "aws_lambda_function" "notification_function" {
  function_name    = "${var.project_name}-notification-${var.environment}"
  role             = aws_iam_role.lambda_notification_execution_role.arn
  package_type     = "Zip"
  runtime          = "python3.13"
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_bootstrap.output_path
  source_code_hash = data.archive_file.lambda_bootstrap.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = {
      REGION                   = var.aws_region
      S3_BUCKET_NAME           = var.s3_bucket_name
      ENVIRONMENT              = var.environment
      PROJECT_NAME             = var.project_name
      URL_SERVICE_TECH         = var.url_service_tech
      API_GATEWAY_DOWNLOAD_URL = var.api_gateway_download_url
    }
  }

  tags = {
    Name        = "${var.project_name}-notification-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "notification_logs" {
  name              = "/aws/lambda/${aws_lambda_function.notification_function.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-notification-logs-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_lambda_event_source_mapping" "notification_sqs_trigger" {
  event_source_arn                   = var.notification_queue_arn
  function_name                      = aws_lambda_function.notification_function.arn
  batch_size                         = 1
  maximum_batching_window_in_seconds = 5

  scaling_config {
    maximum_concurrency = 2
  }

  function_response_types = ["ReportBatchItemFailures"]

  tags = {
    Name        = "${var.project_name}-notification-sqs-trigger-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}
