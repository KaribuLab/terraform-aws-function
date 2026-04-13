output "role_name" {
  value       = aws_iam_role.function.name
  description = "Role name"
}

output "role_id" {
  value       = aws_iam_role.function.id
  description = "Role ID"
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
