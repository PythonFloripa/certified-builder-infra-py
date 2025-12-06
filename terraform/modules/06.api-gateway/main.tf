# Módulo API Gateway REST para Certified Builder API
# Responsável por criar o API Gateway REST com integração ao Lambda de forma escalável

# Definição da estrutura de endpoints da API de forma declarativa
locals {
  # Estrutura hierárquica dos endpoints
  api_structure = {
    "api" = {
      "v1" = {
        "certificate" = {
          endpoints = {
            "create" = {
              method = "POST"
              authorization = "NONE"
              api_key_required = true  # Exige API Key
              lambda_integration = true
              cors_enabled = true
            }
            # Endpoint para criação em lote de certificados
            "create-batch" = {
              method = "POST"
              authorization = "NONE"
              api_key_required = true  # Exige API Key para operações em lote
              lambda_integration = true
              cors_enabled = true
            }
            # Exemplo de como adicionar novos endpoints facilmente:
            # "list" = {
            #   method = "GET"
            #   authorization = "NONE"
            #   lambda_integration = true
            #   cors_enabled = true
            # }
            "fetch" = {
              method = "GET"
              query_string_parameters = {
                /* Endpoint unificado para busca de certificados.
                  Suporta busca por order_id, email, product_id ou combinações.
                  
                  Query Parameters (todos opcionais, mas pelo menos um deve ser fornecido):
                  - order_id: Busca certificados por ID do pedido (string)
                  - email: Busca certificados por email do participante (string válido)
                  - product_id: Busca certificados por ID do produto (string)
                  
                  Combinações válidas:
                  - order_id (sozinho)
                  - email (sozinho) 
                  - product_id (sozinho)
                  - email + product_id (combinação específica)
                  - order_id + product_id (para filtragem adicional)
                */
                "order_id" = false    # Query parameter opcional
                "email" = false       # Query parameter opcional 
                "product_id" = false  # Query parameter opcional
              }
              authorization = "NONE"
              api_key_required = true  # Exige API Key
              lambda_integration = true
              cors_enabled = true
              # Validação será realizada no Lambda, não no API Gateway
              # pois precisamos verificar se pelo menos um parâmetro foi fornecido
            }
            "download" = {
              method = "GET"
              query_string_parameters = {
                /* Endpoint para download de certificados via URL pré-assinada do S3.
                  
                  Query Parameters:
                  - id: UUID do certificado (obrigatório)
                  
                  Retorna:
                  - HTML com redirecionamento automático para URL pré-assinada (30min)
                  - HTML informativo se certificado não foi gerado
                  - 404 se certificado não encontrado ou UUID inválido
                */
                "id" = true    # UUID do certificado (obrigatório)
              }
              authorization = "NONE"
              api_key_required = false  # Não exige API Key para downloads
              lambda_integration = true
              cors_enabled = true
            }
          }
        }
        # Exemplo de como adicionar novos recursos facilmente:
        # "orders" = {
        #   endpoints = {
        #     "create" = {
        #       method = "POST"
        #       authorization = "NONE"
        #       lambda_integration = true
        #       cors_enabled = true
        #     }
        #   }
        # }
      }
    }
  }

  # Flatten da estrutura para criar recursos dinamicamente
  api_paths = flatten([
    for level1_key, level1_value in local.api_structure : [
      for level2_key, level2_value in level1_value : [
        for level3_key, level3_value in level2_value : [
          for endpoint_key, endpoint_config in level3_value.endpoints : {
            path_key = "${level1_key}-${level2_key}-${level3_key}-${endpoint_key}"
            level1 = level1_key
            level2 = level2_key
            level3 = level3_key
            endpoint = endpoint_key
            full_path = "/${level1_key}/${level2_key}/${level3_key}/${endpoint_key}"
            config = endpoint_config
          }
        ]
      ]
    ]
  ])

  # Criar mapa para facilitar referências
  paths_map = {
    for path in local.api_paths : path.path_key => path
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "API REST para Certified Builder API - ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Criação dinâmica dos recursos de primeiro nível (/api)
resource "aws_api_gateway_resource" "level1_resources" {
  for_each = toset([for path in local.api_paths : path.level1])
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value
}

# Criação dinâmica dos recursos de segundo nível (/api/v1)
resource "aws_api_gateway_resource" "level2_resources" {
  for_each = toset([for path in local.api_paths : "${path.level1}/${path.level2}"])
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.level1_resources[split("/", each.value)[0]].id
  path_part   = split("/", each.value)[1]
}

# Criação dinâmica dos recursos de terceiro nível (/api/v1/certificate)
resource "aws_api_gateway_resource" "level3_resources" {
  for_each = toset([for path in local.api_paths : "${path.level1}/${path.level2}/${path.level3}"])
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.level2_resources["${split("/", each.value)[0]}/${split("/", each.value)[1]}"].id
  path_part   = split("/", each.value)[2]
}

# Criação dinâmica dos recursos de quarto nível (/api/v1/certificate/create)
resource "aws_api_gateway_resource" "endpoint_resources" {
  for_each = local.paths_map
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.level3_resources["${each.value.level1}/${each.value.level2}/${each.value.level3}"].id
  path_part   = each.value.endpoint
}

# Criação dinâmica dos métodos HTTP
resource "aws_api_gateway_method" "endpoint_methods" {
  for_each = local.paths_map
  
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.endpoint_resources[each.key].id
  http_method   = each.value.config.method
  authorization = each.value.config.authorization
  api_key_required = lookup(each.value.config, "api_key_required", false)

  # Configuração dos parâmetros de requisição incluindo query parameters
  request_parameters = merge(
    {
      "method.request.header.Content-Type" = true
    },
    # Adiciona query parameters se definidos na configuração do endpoint
    can(each.value.config.query_string_parameters) ? {
      for param_name, required in each.value.config.query_string_parameters :
      "method.request.querystring.${param_name}" => required
    } : {}
  )
}

# Criação dinâmica das integrações com Lambda
resource "aws_api_gateway_integration" "lambda_integrations" {
  for_each = {
    for key, path in local.paths_map : key => path
    if path.config.lambda_integration
  }
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.endpoint_resources[each.key].id
  http_method = aws_api_gateway_method.endpoint_methods[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# Permissão para API Gateway invocar o Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  
  # Permite qualquer método do API Gateway (mais flexível para múltiplos endpoints)
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Criação dinâmica dos métodos OPTIONS para CORS
resource "aws_api_gateway_method" "cors_methods" {
  for_each = {
    for key, path in local.paths_map : key => path
    if path.config.cors_enabled
  }
  
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.endpoint_resources[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Criação dinâmica das integrações MOCK para CORS
resource "aws_api_gateway_integration" "cors_integrations" {
  for_each = {
    for key, path in local.paths_map : key => path
    if path.config.cors_enabled
  }
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.endpoint_resources[each.key].id
  http_method = aws_api_gateway_method.cors_methods[each.key].http_method

  type = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Criação dinâmica das respostas CORS
resource "aws_api_gateway_method_response" "cors_responses" {
  for_each = {
    for key, path in local.paths_map : key => path
    if path.config.cors_enabled
  }
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.endpoint_resources[each.key].id
  http_method = aws_api_gateway_method.cors_methods[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Criação dinâmica das respostas de integração CORS
resource "aws_api_gateway_integration_response" "cors_integration_responses" {
  for_each = {
    for key, path in local.paths_map : key => path
    if path.config.cors_enabled
  }
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.endpoint_resources[each.key].id
  http_method = aws_api_gateway_method.cors_methods[each.key].http_method
  status_code = aws_api_gateway_method_response.cors_responses[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'${each.value.config.method},OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Deployment do API Gateway com triggers dinâmicos
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_method.endpoint_methods,
    aws_api_gateway_integration.lambda_integrations,
    aws_api_gateway_method.cors_methods,
    aws_api_gateway_integration.cors_integrations
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  # Triggers dinâmicos baseados na estrutura da API
  triggers = {
    redeployment = sha1(jsonencode([
      local.api_structure,
      var.lambda_invoke_arn
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage do API Gateway
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.environment

  # Configuração de logs (desabilitada por padrão para economizar)
  xray_tracing_enabled = false

  tags = {
    Name        = "${var.project_name}-api-stage-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Configuração de throttling para controle de custos
resource "aws_api_gateway_method_settings" "api_throttling" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/*"

  settings {
    throttling_rate_limit  = var.throttle_rate_limit
    throttling_burst_limit = var.throttle_burst_limit
    logging_level          = "OFF"
    data_trace_enabled     = false
    metrics_enabled        = false
  }
}

# ==============================
# CONFIGURAÇÃO DE API KEY
# ==============================

# API Key para autenticação
resource "aws_api_gateway_api_key" "main_api_key" {
  name        = "${var.project_name}-api-key-${var.environment}"
  description = "API Key para autenticação do ${var.project_name} em ${var.environment}"
  enabled     = true
  
  # Valor da API Key configurável via variável
  value = var.api_key_value

  tags = {
    Name        = "${var.project_name}-api-key-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Usage Plan para controlar o uso da API Key
resource "aws_api_gateway_usage_plan" "main_usage_plan" {
  name         = "${var.project_name}-usage-plan-${var.environment}"
  description  = "Usage plan para ${var.project_name} em ${var.environment}"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }

  quota_settings {
    limit  = 1000  # 1k requests por mês
    period = "MONTH"
  }

  throttle_settings {
    rate_limit  = var.throttle_rate_limit   # requests por segundo
    burst_limit = var.throttle_burst_limit  # burst máximo
  }

  tags = {
    Name        = "${var.project_name}-usage-plan-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Vinculação da API Key ao Usage Plan
resource "aws_api_gateway_usage_plan_key" "main_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.main_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main_usage_plan.id
}

# Method settings específicos para endpoint de download com rate limit muito baixo
resource "aws_api_gateway_method_settings" "download_throttling" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/certificate/download/GET"

  settings {
    throttling_rate_limit  = 0.083  # ~5 requests por minuto
    throttling_burst_limit = 2      # burst máximo muito baixo
    metrics_enabled        = true
  }
}

# Usage Plan específico para endpoint de download com rate limit muito baixo
resource "aws_api_gateway_usage_plan" "download_usage_plan" {
  name         = "${var.project_name}-download-usage-plan-${var.environment}"
  description  = "Usage plan restritivo para endpoint de download de certificados"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }

  quota_settings {
    limit  = 50   # 50 requests por mês
    period = "MONTH"
  }

  throttle_settings {
    rate_limit  = 0.083  # ~5 requests por minuto (5/60 = 0.083)
    burst_limit = 2      # burst máximo muito baixo
  }

  tags = {
    Name        = "${var.project_name}-download-usage-plan-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "download-rate-limiting"
  }
}

# ==============================
# OUTPUTS PARA API KEY
# ==============================
