# Outputs do módulo Lambda

output "function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.api_function.function_name
}

output "function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.api_function.arn
}

output "invoke_arn" {
  description = "ARN para invocar a função Lambda"
  value       = aws_lambda_function.api_function.invoke_arn
}

output "role_arn" {
  description = "ARN da role IAM da função Lambda"
  value       = aws_iam_role.lambda_execution_role.arn
}

# Outputs da função Lambda Builder
output "builder_function_name" {
  description = "Nome da função Lambda Builder"
  value       = aws_lambda_function.builder_funcition.function_name
}

output "builder_function_arn" {
  description = "ARN da função Lambda Builder"
  value       = aws_lambda_function.builder_funcition.arn
}

output "builder_invoke_arn" {
  description = "ARN para invocar a função Lambda Builder"
  value       = aws_lambda_function.builder_funcition.invoke_arn
}

output "builder_role_arn" {
  description = "ARN da role IAM da função Lambda Builder"
  value       = aws_iam_role.lambda_builder_execution_role.arn
}

# Output do Event Source Mapping (trigger SQS → Lambda)
output "builder_sqs_trigger_uuid" {
  description = "UUID do trigger SQS para Lambda Builder"
  value       = aws_lambda_event_source_mapping.builder_sqs_trigger.uuid
}
