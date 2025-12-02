# Configuração e Uso da API Key

## 🔑 **Implementação Completa de API Key**

A API agora exige autenticação via API Key para todos os endpoints protegidos.

## 📋 **Configuração Implementada**

### **1. Endpoints que Exigem API Key:**
- `POST /api/v1/certificate/create`
- `GET /api/v1/certificate/fetch`

### **2. Header Obrigatório:**
```
X-API-Key: 8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29
```

### **3. Recursos Criados:**
- **API Key**: `aws_api_gateway_api_key.main_api_key`
- **Usage Plan**: `aws_api_gateway_usage_plan.main_usage_plan`
- **Vinculação**: `aws_api_gateway_usage_plan_key.main_usage_plan_key`

## 🔧 **Como Funciona**

### **1. Validação no API Gateway:**
- O API Gateway valida automaticamente o header `X-API-Key`
- Se não fornecido ou inválido: **HTTP 403 Forbidden**
- Se válido: request é encaminhado para a Lambda

### **2. Controle de Uso:**
- **Quota**: 10.000 requests/mês
- **Rate Limit**: Configurável via `throttle_rate_limit`
- **Burst Limit**: Configurável via `throttle_burst_limit`

## 🚀 **Como Usar na Aplicação**

### **JavaScript/Node.js:**
```javascript
const response = await fetch('https://your-api-gateway-url/api/v1/certificate/create', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': '8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29'
  },
  body: JSON.stringify({
    // seus dados aqui
  })
});
```

### **cURL:**
```bash
curl -X POST \
  'https://your-api-gateway-url/api/v1/certificate/create' \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: 8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29' \
  -d '{
    "order_id": "123",
    "participant_email": "test@example.com"
  }'
```

### **Python:**
```python
import requests

headers = {
    'Content-Type': 'application/json',
    'X-API-Key': '8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29'
}

response = requests.post(
    'https://your-api-gateway-url/api/v1/certificate/create',
    headers=headers,
    json={
        'order_id': '123',
        'participant_email': 'test@example.com'
    }
)
```

## 🔒 **Gerenciamento da API Key**

### **1. Valor Atual:**
```
8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29
```

### **2. Alteração da API Key:**
```hcl
# No arquivo terraform.tfvars
api_key_value = "nova-uuid-aqui"
```

### **3. Rotação da API Key:**
1. Altere o valor em `terraform.tfvars`
2. Execute: `terraform apply`
3. Atualize todas as aplicações cliente
4. **Importante**: A API Key antiga para de funcionar imediatamente

## 📊 **Monitoramento e Outputs**

### **Outputs Disponíveis:**
```bash
# Obter informações da API Key
terraform output api_key_id
terraform output usage_plan_id

# API Key value (sensível)
terraform output -json api_key_value
```

### **URLs dos Endpoints:**
```bash
# Endpoint de criação
terraform output api_endpoint_create_certificate

# Endpoint de busca
terraform output api_endpoint_fetch_certificate
```

## 🛡️ **Segurança**

### **1. API Key como Variável Sensível:**
- Marcada como `sensitive = true`
- Não aparece em logs do Terraform
- Protegida no state file

### **2. Validação de Formato:**
- Só aceita UUIDs válidos
- Formato: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

### **3. Controle de Acesso:**
- Usage Plan limita o uso por API Key
- Throttling previne abuso
- Logs de acesso no CloudWatch

## ⚠️ **Troubleshooting**

### **403 Forbidden:**
```json
{
  "message": "Forbidden"
}
```
**Solução**: Verificar se o header `X-API-Key` está correto.

### **429 Too Many Requests:**
```json
{
  "message": "Too Many Requests"
}
```
**Solução**: Aguardar ou ajustar limites no Usage Plan.

### **Verificação da API Key:**
```bash
# No AWS CLI
aws apigateway get-api-key --api-key your-api-key-id --include-value
```

## 📝 **Exemplo Completo de Teste**

```bash
# 1. Obter URL do endpoint
API_URL=$(terraform output -raw api_endpoint_create_certificate)

# 2. Testar com API Key
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: 8a3f1e2c-9d7b-4f4a-8453-bf3c1d2a6f29" \
  -d '{"order_id": "test123", "participant_email": "test@example.com"}'

# 3. Testar SEM API Key (deve falhar)
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{"order_id": "test123", "participant_email": "test@example.com"}'
```

A implementação está completa e todos os endpoints agora exigem a API Key especificada!
