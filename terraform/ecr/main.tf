# Módulo ECR para Certified Builder API
# Responsável por criar o repositório de imagens Docker da aplicação

resource "aws_ecr_repository" "api_repository" {
  
  name                 = var.api_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true  # Permite deletar o repositório mesmo com imagens

  # Configuração de scan de segurança
  image_scanning_configuration {
    scan_on_push = true
  }

  # Política de ciclo de vida para otimizar custos
  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name        = var.api_repository_name
    Project     = var.project_name
  }
}

resource "aws_ecr_repository" "builder_repository" {
  name                 = var.builder_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true  # Permite deletar o repositório mesmo com imagens

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.builder_repository_name
    Project     = var.project_name
  }
}

# Política de ciclo de vida para manter apenas as últimas 1 imagens
resource "aws_ecr_lifecycle_policy" "api_repository_policy" {
  repository = aws_ecr_repository.api_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1  
        description  = "Manter apenas as últimas 1 imagens para otimizar custos"
        selection = {
          tagStatus     = "untagged"
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Manter apenas as últimas 1 imagens taggeadas"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "builder_repository_policy" {
  repository = aws_ecr_repository.builder_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1  
        description  = "Manter apenas as últimas 1 imagens para otimizar custos"
        selection = {
          tagStatus     = "untagged"
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Manter apenas as últimas 1 imagens taggeadas"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}