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