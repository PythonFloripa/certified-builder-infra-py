# API Gateway - Estrutura Escalável

Este módulo implementa uma organização escalável e dinâmica para o AWS API Gateway usando Terraform.

## ✨ Vantagens da Nova Estrutura

### 🔄 **Antes (Código Manual)**
- ❌ Cada endpoint precisava de 4-5 recursos separados
- ❌ Código repetitivo e difícil manutenção  
- ❌ Para adicionar `/api/v1/certificate/list` = +15 linhas de código
- ❌ CORS configurado manualmente para cada endpoint

### 🚀 **Depois (Código Dinâmico)**
- ✅ Estrutura declarativa em `locals`
- ✅ Recursos criados automaticamente com `for_each`
- ✅ Para adicionar `/api/v1/certificate/list` = +7 linhas simples
- ✅ CORS automático para todos os endpoints

## 📖 Como Adicionar Novos Endpoints

### 1. **Novo Endpoint no Recurso Existente**

Para adicionar `GET /api/v1/certificate/list`:

```hcl
# No locals.api_structure, dentro de certificate.endpoints:
"list" = {
  method = "GET"
  authorization = "NONE"
  lambda_integration = true
  cors_enabled = true
}
```

### 2. **Novo Recurso Completo**

Para adicionar `POST /api/v1/orders/create`:

```hcl
# No locals.api_structure, dentro de v1:
"orders" = {
  endpoints = {
    "create" = {
      method = "POST"
      authorization = "NONE"
      lambda_integration = true
      cors_enabled = true
    }
    "list" = {
      method = "GET"
      authorization = "NONE"
      lambda_integration = true
      cors_enabled = true
    }
  }
}
```

### 3. **Nova Versão da API**

Para adicionar `POST /api/v2/certificate/create`:

```hcl
# No locals.api_structure, dentro de api:
"v2" = {
  "certificate" = {
    endpoints = {
      "create" = {
        method = "POST"
        authorization = "NONE"
        lambda_integration = true
        cors_enabled = true
      }
    }
  }
}
```

## ⚙️ Configurações Disponíveis

### Opções por Endpoint:

```hcl
"endpoint_name" = {
  method = "POST|GET|PUT|DELETE|PATCH"  # Método HTTP
  authorization = "NONE|AWS_IAM|COGNITO_USER_POOLS"  # Tipo de autorização
  lambda_integration = true|false        # Integração com Lambda
  cors_enabled = true|false             # Habilitar CORS automático
}
```

## 🔧 Funcionalidades Automáticas

### 1. **Recursos Hierárquicos**
- Cria automaticamente toda a estrutura de recursos
- Gerencia dependências entre níveis
- Evita duplicação de recursos

### 2. **CORS Inteligente**
- Métodos OPTIONS criados automaticamente
- Headers CORS configurados dinamicamente
- Permite métodos específicos por endpoint

### 3. **Deployment Inteligente**
- Trigger automático quando estrutura muda
- Dependency tracking completo
- Zero downtime com `create_before_destroy`

### 4. **Integração Lambda**
- Uma única permissão para todos os endpoints
- Proxy integration automática
- URN flexível para múltiplas funções

## 📊 Exemplo de Estrutura Completa

```hcl
api_structure = {
  "api" = {
    "v1" = {
      "certificate" = {
        endpoints = {
          "create" = { method = "POST", authorization = "NONE", lambda_integration = true, cors_enabled = true }
          "list"   = { method = "GET",  authorization = "NONE", lambda_integration = true, cors_enabled = true }
          "status" = { method = "GET",  authorization = "NONE", lambda_integration = true, cors_enabled = true }
        }
      }
      "orders" = {
        endpoints = {
          "create" = { method = "POST", authorization = "NONE", lambda_integration = true, cors_enabled = true }
          "list"   = { method = "GET",  authorization = "NONE", lambda_integration = true, cors_enabled = true }
        }
      }
      "health" = {
        endpoints = {
          "check" = { method = "GET", authorization = "NONE", lambda_integration = true, cors_enabled = false }
        }
      }
    }
    "v2" = {
      "certificate" = {
        endpoints = {
          "create" = { method = "POST", authorization = "AWS_IAM", lambda_integration = true, cors_enabled = true }
        }
      }
    }
  }
}
```

### URLs Geradas:
- `POST /api/v1/certificate/create`
- `GET /api/v1/certificate/list`
- `GET /api/v1/certificate/status`
- `POST /api/v1/orders/create`
- `GET /api/v1/orders/list`
- `GET /api/v1/health/check`
- `POST /api/v2/certificate/create`

## 🚦 Migration Path

Para migrar endpoints existentes:

1. **Mantenha o código antigo** temporariamente
2. **Adicione o endpoint na nova estrutura**
3. **Teste que ambos funcionam**
4. **Remova o código antigo**
5. **Execute `terraform apply`**

## 💡 Melhores Práticas

1. **Sempre use `cors_enabled = true`** para endpoints web
2. **Mantenha estrutura hierárquica consistente**
3. **Use nomes descritivos para endpoints**
4. **Considere autenticação por endpoint**
5. **Teste mudanças em ambiente de desenvolvimento primeiro**
