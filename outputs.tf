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
output "secrets_manager_client_ids" {
  description = "Map of Auth0 client IDs to their Secrets Manager secret names for client IDs"
  value = {
    for k, v in aws_secretsmanager_secret.auth0_client_ids : 
      k => v.name
  }
}

output "secrets_manager_client_secrets" {
  description = "Map of Auth0 client IDs to their Secrets Manager secret names for client secrets"
  value = {
    for k, v in aws_secretsmanager_secret.auth0_client_secrets : 
      k => v.name
  }
}

output "secrets_manager_arns" {
  description = "Map of all created secrets with their ARNs"
  value = {
    client_ids = {
      for k, v in aws_secretsmanager_secret.auth0_client_ids : 
        k => v.arn
    }
    client_secrets = {
      for k, v in aws_secretsmanager_secret.auth0_client_secrets : 
        k => v.arn
    }
  }
  sensitive = true
}

output "secrets_manager_retrieval_commands" {
  description = "AWS CLI commands to retrieve the secrets for each client"
  value = {
    for k, v in local.clients_map :
      "${v.name} (${substr(k, 0, 8)})" => {
        client_id     = "aws secretsmanager get-secret-value --secret-id '${aws_secretsmanager_secret.auth0_client_ids[k].name}' --region ${var.aws_region} --query SecretString --output text"
        client_secret = "aws secretsmanager get-secret-value --secret-id '${aws_secretsmanager_secret.auth0_client_secrets[k].name}' --region ${var.aws_region} --query SecretString --output text"
      }
  }
}