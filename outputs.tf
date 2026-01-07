# Auth0 Application Credentials
output "auth0_client_id" {
  description = "Auth0 application client ID"
  value       = auth0_client.express_app.client_id
}

output "auth0_client_secret" {
  description = "Auth0 application client secret"
  value       = auth0_client_credentials.express_app.client_secret
  sensitive   = true
}

output "auth0_domain" {
  description = "Auth0 domain"
  value       = var.auth0_domain
}

# AWS Secrets Manager Outputs
output "secrets_manager_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing Auth0 credentials"
  value       = aws_secretsmanager_secret.auth0_credentials.name
}

output "secrets_manager_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing Auth0 credentials"
  value       = aws_secretsmanager_secret.auth0_credentials.arn
}

output "secrets_manager_retrieval_command" {
  description = "AWS CLI command to retrieve the secret"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.auth0_credentials.name} --region ${var.aws_region} --query SecretString --output text | jq ."
}