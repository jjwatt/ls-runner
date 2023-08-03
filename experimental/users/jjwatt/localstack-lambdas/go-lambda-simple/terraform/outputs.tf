output "lambda_arn" {
  description = "The Amazon Resource Name identifying your Lambda Function."
  value       = aws_lambda_function.lambda.arn
}

output "lambda_function_name" {
  description = "The unique name of your Lambda Function."
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
  value       = aws_lambda_function.lambda.invoke_arn
}

output "lambda_role_name" {
  description = "The name of the IAM attached to the Lambda Function."
  value       = aws_iam_role.lambda.name
}

output "lambda_version" {
  description = "Latest published version of your Lambda Function."
  value       = aws_lambda_function.lambda.version
}
