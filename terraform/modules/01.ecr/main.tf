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


resource "aws_ecr_repository" "notification_repository" {
  name                 = var.notification_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true  # Permite deletar o repositório mesmo com imagens

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.notification_repository_name
    Project     = var.project_name
  }
}


# Política de ciclo de vida otimizada para manter apenas 1 imagem por tag
resource "aws_ecr_lifecycle_policy" "api_repository_policy" {
  repository = aws_ecr_repository.api_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove imagens não-taggeadas imediatamente (exceto a mais recente)"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Mantém apenas 1 imagem por tag específica - remove versões antigas"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging", "main"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Remove qualquer imagem taggeada com mais de 1 dia (fallback de segurança)"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging", "main", "feature", "hotfix"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
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
        description  = "Remove imagens não-taggeadas imediatamente (exceto a mais recente)"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Mantém apenas 1 imagem por tag específica - remove versões antigas"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging", "main"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Remove qualquer imagem taggeada com mais de 1 dia (fallback de segurança)"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging", "main", "feature", "hotfix"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


resource "aws_ecr_lifecycle_policy" "notification_repository_policy" {
  repository = aws_ecr_repository.notification_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove imagens não-taggeadas imediatamente (exceto a mais recente)"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Mantém apenas 1 imagem por tag específica - remove versões antigas"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging", "main"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Remove qualquer imagem taggeada com mais de 1 dia (fallback de segurança)"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest", "v", "dev", "prod", "staging", "main", "feature", "hotfix"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}