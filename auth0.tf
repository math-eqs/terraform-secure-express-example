# Create Auth0 Application (Regular Web Application for your Express app)
resource "auth0_client" "express_app" {
  name         = "${var.app_name} - ${var.app_environment}"
  description  = "Express application managed by Terraform"
  app_type     = "regular_web"
  
  # Application settings
  callbacks    = var.allowed_callback_urls
  allowed_logout_urls = var.allowed_logout_urls
  web_origins  = var.allowed_logout_urls
  
  # OAuth settings
  oidc_conformant = true
  
  # Grant types
  grant_types = [
    "authorization_code",
    "refresh_token"
  ]
  
  # JWT settings
  jwt_configuration {
    lifetime_in_seconds = 36000
    secret_encoded      = true
    alg                 = "HS256"
  }
  
  # Refresh token settings
  refresh_token {
    leeway          = 0
    token_lifetime  = 2592000
    rotation_type   = "rotating"
    expiration_type = "expiring"
  }

  # Additional metadata
  client_metadata = {
    environment = var.app_environment
    managed_by  = "terraform"
  }
}

# Configure client credentials to access the client_secret
# Note: Your Terraform Management API client needs the "read:client_keys" scope
resource "auth0_client_credentials" "express_app" {
  client_id = auth0_client.express_app.id

  authentication_method = "client_secret_post"
}

# Create an API for your application (optional but recommended)
resource "auth0_resource_server" "express_api" {
  name       = "${var.app_name} API - ${var.app_environment}"
  identifier = "https://api.${replace(lower(var.app_name), " ", "-")}-${var.app_environment}.local"
  
  # API settings
  signing_alg                = "RS256"
  allow_offline_access       = true
  token_lifetime             = 86400
  token_lifetime_for_web     = 7200
  skip_consent_for_verifiable_first_party_clients = true
  
  # Scopes (you can customize these based on your needs)
  scopes {
    value       = "read:profile"
    description = "Read user profile"
  }
  
  scopes {
    value       = "write:profile"
    description = "Write user profile"
  }
}

# Create a Machine-to-Machine application for API access (if needed)
resource "auth0_client" "m2m_app" {
  count = var.app_environment == "prod" ? 1 : 0
  
  name        = "${var.app_name} M2M - ${var.app_environment}"
  description = "Machine-to-Machine application for ${var.app_name}"
  app_type    = "non_interactive"
  
  # Grant types for M2M
  grant_types = ["client_credentials"]
  
  # JWT configuration
  jwt_configuration {
    lifetime_in_seconds = 36000
    secret_encoded      = true
    alg                 = "RS256"
  }
}

# Grant M2M app access to the API
resource "auth0_client_grant" "m2m_grant" {
  count = var.app_environment == "prod" ? 1 : 0
  
  client_id = auth0_client.m2m_app[0].id
  audience  = auth0_resource_server.express_api.identifier
  
  scope = [
    "read:profile",
    "write:profile"
  ]
}

# Configure M2M client credentials
resource "auth0_client_credentials" "m2m_app" {
  count = var.app_environment == "prod" ? 1 : 0
  
  client_id = auth0_client.m2m_app[0].id
  authentication_method = "client_secret_post"
}