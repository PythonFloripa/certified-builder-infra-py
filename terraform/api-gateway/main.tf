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
            # "status" = {
            #   method = "GET"
            #   authorization = "NONE"
            #   lambda_integration = true
            #   cors_enabled = true
            # }
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

  request_parameters = {
    "method.request.header.Content-Type" = true
  }
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

# Configuração removida - agora CORS é criado dinamicamente acima
