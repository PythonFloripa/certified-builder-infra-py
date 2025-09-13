
# Certified Builder Infra PY

## Visão Geral do Projeto

Este projeto contém a infraestrutura como código (IaC) para a aplicação "Certified Builder". A infraestrutura é gerenciada com Terraform e provisiona os recursos necessários na AWS para executar a aplicação de forma escalável e econômica.

## Tecnologias Utilizadas

- **Terraform**: Ferramenta de infraestrutura como código para provisionar e gerenciar os recursos na nuvem.
- **AWS (Amazon Web Services)**: Provedor de nuvem onde a infraestrutura da aplicação é hospedada.

## Estrutura de Pastas

A estrutura de pastas do projeto é organizada da seguinte forma:

```
/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── api-gateway/
│   ├── bucket_s3/
│   ├── dynamodb/
│   │   ├── certificates/
│   │   ├── orders/
│   │   ├── participants/
│   │   └── products/
│   ├── ecr/
│   ├── lambda/
│   └── sqs/
└── README.md
```

- **terraform/**: Contém todos os arquivos de configuração do Terraform.
- **terraform/main.tf**: Arquivo principal que define os módulos e a configuração do provider.
- **terraform/variables.tf**: Declaração das variáveis utilizadas no projeto.
- **terraform/outputs.tf**: Definição dos outputs do Terraform.
- **terraform/terraform.tfvars.example**: Arquivo de exemplo para as variáveis do Terraform.
- **terraform/[module]/**: Cada pasta representa um módulo do Terraform que provisiona um serviço específico na AWS.

## Serviços Criados e Suas Variáveis

A seguir estão os serviços da AWS criados por este projeto e suas respectivas variáveis de configuração.

### API Gateway

- **Descrição**: Cria um API Gateway REST para expor a aplicação Lambda como uma API.
- **Variáveis**:
    - `project_name`: Nome do projeto.
    - `environment`: Ambiente de deploy (dev, staging, prod).
    - `lambda_function_name`: Nome da função Lambda.
    - `lambda_invoke_arn`: ARN para invocar a função Lambda.
    - `throttle_rate_limit`: Limite de taxa por segundo para throttling.
    - `throttle_burst_limit`: Limite de burst para throttling.
    - `api_key_value`: Valor da API Key para autenticação.

### S3 Bucket

- **Descrição**: Cria um bucket S3 para armazenar os arquivos do projeto.
- **Variáveis**:
    - `bucket_name`: Nome do bucket S3.
    - `environment`: Ambiente de deploy.
    - `project_name`: Nome do projeto.
    - `region`: Região da AWS.
    - `lifecycle_rule`: Regras de ciclo de vida dos objetos S3.

### DynamoDB

- **Descrição**: Cria as tabelas do DynamoDB para a aplicação.
- **Módulos**:
    - `certificates`: Tabela de certificados.
    - `orders`: Tabela de pedidos.
    - `participants`: Tabela de participantes.
    - `products`: Tabela de produtos.
- **Variáveis (por módulo)**:
    - `table_name`: Nome da tabela.
    - `environment`: Ambiente de deploy.
    - `project_name`: Nome do projeto.

### ECR (Elastic Container Registry)

- **Descrição**: Cria os repositórios de imagens Docker para a aplicação.
- **Variáveis**:
    - `project_name`: Nome do projeto.
    - `api_repository_name`: Nome do repositório ECR para a API.
    - `builder_repository_name`: Nome do repositório ECR para o builder.
    - `notification_repository_name`: Nome do repositório ECR para o notificador.

### Lambda

- **Descrição**: Cria as funções Lambda que executam a aplicação containerizada.
- **Variáveis**:
    - `project_name`: Nome do projeto.
    - `environment`: Ambiente de deploy.
    - `aws_region`: Região AWS.
    - `ecr_api_repository_name`: Nome do repositório ECR da API.
    - `ecr_api_repository_url`: URL do repositório ECR da API.
    - `ecr_builder_repository_name`: Nome do repositório ECR do builder.
    - `ecr_builder_repository_url`: URL do repositório ECR do builder.
    - `ecr_builder_repository_arn`: ARN do repositório ECR do builder.
    - `ecr_notification_repository_name`: Nome do repositório ECR do notificador.
    - `ecr_notification_repository_url`: URL do repositório ECR do notificador.
    - `ecr_notification_repository_arn`: ARN do repositório ECR do notificador.
    - `image_tag`: Tag da imagem Docker.
    - `lambda_timeout`: Timeout da função Lambda em segundos.
    - `lambda_memory_size`: Memória alocada para a função Lambda em MB.
    - `log_retention_days`: Dias de retenção dos logs do CloudWatch.
    - `builder_queue_url`: URL da fila SQS builder.
    - `url_service_tech`: URL do serviço Tech Floripa.
    - `prefix_api_version`: Prefixo da versão da API.
    - `dynamodb_table_arns`: ARNs das tabelas DynamoDB.
    - `builder_queue_arn`: ARN da fila SQS builder.
    - `notification_queue_arn`: ARN da fila SQS notification.
    - `notification_queue_url`: URL da fila SQS notification.
    - `ecr_repository_arn`: ARN do repositório ECR.
    - `s3_bucket_arn`: ARN do bucket S3.
    - `s3_bucket_name`: Nome do bucket S3.
    - `api_gateway_download_url`: URL base do endpoint de download do API Gateway.

### SQS (Simple Queue Service)

- **Descrição**: Cria as filas SQS para processamento assíncrono.
- **Variáveis**:
    - `project_name`: Nome do projeto.
    - `environment`: Ambiente de deploy.
    - `queue_name_builder`: Nome da fila de build.
    - `queue_name_builder_dlq`: Nome da fila de build DLQ.
    - `queue_name_notification`: Nome da fila de notificação.
    - `queue_name_notification_dlq`: Nome da fila de notificação DLQ.
