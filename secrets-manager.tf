# Fetch all Auth0 clients from the Management API
data "auth0_clients" "all" {
  # No filters - fetches all clients from Auth0
}

# Create a map of clients by client_id for easier reference
locals {
  clients_map = {
    for client in data.auth0_clients.all.clients : 
      client.client_id => client
  }
  
  # Sanitize client names for AWS Secrets Manager (only alphanumeric, /_+=.@-)
  # Replace spaces and invalid chars with hyphens, make unique with client_id suffix
  sanitized_names = {
    for client_id, client in local.clients_map :
      client_id => replace(
        replace(client.name, "/[^a-zA-Z0-9/_+=.@-]/", "-"),
        "/--+/", "-"
      )
  }
}

# Create AWS Secrets Manager secret for each Auth0 Client ID
# Format: {environment}/{application_name}/client_id
resource "aws_secretsmanager_secret" "auth0_client_ids" {
  for_each = local.clients_map
  
  name                    = "auth0/${var.app_environment}/${local.sanitized_names[each.key]}-${substr(each.key, 0, 8)}/client_id"
  description             = "Auth0 Client ID for ${each.value.name} - ${var.app_environment} (from Auth0 Management API)"
  recovery_window_in_days = 7
  
  tags = {
    Environment   = var.app_environment
    Application   = each.value.name
    Auth0ClientID = each.value.client_id
    ManagedBy     = "terraform"
    SecretType    = "auth0-client-id"
    Source        = "auth0-management-api"
    OriginalName  = each.value.name
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Store Auth0 Client ID in Secrets Manager
resource "aws_secretsmanager_secret_version" "auth0_client_ids" {
  for_each = aws_secretsmanager_secret.auth0_client_ids
  
  secret_id     = each.value.id
  secret_string = local.clients_map[each.key].client_id
}

# Create AWS Secrets Manager secret for each Auth0 Client Secret
# Format: {environment}/{application_name}/client_secret
resource "aws_secretsmanager_secret" "auth0_client_secrets" {
  for_each = local.clients_map
  
  name                    = "auth0/${var.app_environment}/${local.sanitized_names[each.key]}-${substr(each.key, 0, 8)}/client_secret"
  description             = "Auth0 Client Secret for ${each.value.name} - ${var.app_environment} (from Auth0 Management API)"
  recovery_window_in_days = 7
  
  tags = {
    Environment   = var.app_environment
    Application   = each.value.name
    Auth0ClientID = each.value.client_id
    ManagedBy     = "terraform"
    SecretType    = "auth0-client-secret"
    Source        = "auth0-management-api"
    OriginalName  = each.value.name
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Store Auth0 Client Secret in Secrets Manager
resource "aws_secretsmanager_secret_version" "auth0_client_secrets" {
  for_each = aws_secretsmanager_secret.auth0_client_secrets
  
  secret_id     = each.value.id
  secret_string = local.clients_map[each.key].client_secret
}
