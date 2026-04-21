output "role_name" {
  value       = var.lambda_role_arn != null ? null : aws_iam_role.function[0].name
  description = "Role name"
}

output "role_id" {
  value       = var.lambda_role_arn != null ? null : aws_iam_role.function[0].id
  description = "IAM role unique ID (empty when execution role is supplied via lambda_role_arn)"
}

output "role_arn" {
  value       = length(aws_iam_role.function) > 0 ? aws_iam_role.function[0].arn : var.lambda_role_arn
  description = "Execution role ARN (created by this module or from lambda_role_arn)"
}

output "function_name" {
  value       = aws_lambda_function.function.function_name
  description = "Function name"
}

output "function_url" {
  value       = var.function_url != null ? aws_lambda_function_url.function[0].function_url : null
  description = "Function URL"
}

output "invoke_arn" {
  value       = aws_lambda_function.function.invoke_arn
  description = "Function invoke ARN"
}

output "lambda_arn" {
  value       = aws_lambda_function.function.arn
  description = "Function ARN"
}

output "lambda_version" {
  value       = aws_lambda_function.function.version
  description = "Function version"

}
