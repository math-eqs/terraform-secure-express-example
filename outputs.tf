# Auth0 Application Credentials (Main Output)
output "auth0_client_id" {
  description = "Auth0 application client ID"
  value       = auth0_client.express_app.client_id
}

output "auth0_client_secret" {
  description = "Auth0 application client secret (requires read:client_keys scope on Terraform provider client)"
  value       = auth0_client_credentials.express_app.client_secret
  sensitive   = true
}

output "auth0_domain" {
  description = "Auth0 domain"
  value       = var.auth0_domain
}

output "auth0_api_identifier" {
  description = "Auth0 API identifier"
  value       = auth0_resource_server.express_api.identifier
}

# Complete Application Configuration
output "application_config" {
  description = "Complete Auth0 application configuration"
  value = {
    # Environment variables for your application
    AUTH0_CLIENT_ID     = auth0_client.express_app.client_id
    AUTH0_CLIENT_SECRET = auth0_client_credentials.express_app.client_secret
    AUTH0_CLIENT_DOMAIN = var.auth0_domain
    AUTH0_API_IDENTIFIER = auth0_resource_server.express_api.identifier
    
    # Application details
    app_name = auth0_client.express_app.name
    app_type = auth0_client.express_app.app_type
    callbacks = auth0_client.express_app.callbacks
    logout_urls = auth0_client.express_app.allowed_logout_urls
  }
  sensitive = true
}

# Docker run command with actual values
output "docker_run_command" {
  description = "Docker run command with Auth0 credentials"
  value = <<-EOT
    docker run --name terraform-secure-express -p 3000:3000 \
      --env AUTH0_CLIENT_ID=${auth0_client.express_app.client_id} \
      --env AUTH0_CLIENT_SECRET=${auth0_client_credentials.express_app.client_secret} \
      --env AUTH0_CLIENT_DOMAIN=${var.auth0_domain} \
      --env AUTH0_API_IDENTIFIER=${auth0_resource_server.express_api.identifier} \
      terraform-secure-express:1.0
  EOT
  sensitive = true
}

# M2M Application Information (if created)
output "m2m_client_id" {
  description = "Machine-to-Machine application client ID (if created)"
  value       = var.app_environment == "prod" ? auth0_client.m2m_app[0].client_id : "Not created for this environment"
}

output "m2m_client_secret" {
  description = "Machine-to-Machine application client secret (if created)"
  value       = var.app_environment == "prod" ? auth0_client.m2m_app[0].client_secret : "Not created for this environment"
  sensitive   = true
}

# JSON format for easy copy-paste
output "credentials_json" {
  description = "Auth0 credentials in JSON format"
  value = jsonencode({
    client_id       = auth0_client.express_app.client_id
    client_secret   = auth0_client_credentials.express_app.client_secret
    domain          = var.auth0_domain
    api_identifier  = auth0_resource_server.express_api.identifier
    callback_urls   = auth0_client.express_app.callbacks
    logout_urls     = auth0_client.express_app.allowed_logout_urls
    created_at      = timestamp()
  })
  sensitive = true
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

# IAM Resources for Application
output "app_role_arn" {
  description = "ARN of the IAM role for the application (attach to EC2/ECS/Lambda)"
  value       = aws_iam_role.app_role.arn
}

output "app_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  value       = aws_iam_instance_profile.app_instance_profile.name
}

output "secrets_access_policy_arn" {
  description = "ARN of the IAM policy for accessing Auth0 secrets"
  value       = aws_iam_policy.auth0_secrets_access.arn
}