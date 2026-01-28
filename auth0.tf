# Create Auth0 Application (Machine-to-Machine for Work Orders Legacy API)
resource "auth0_client" "express_app" {
  name            = "Work Orders Legacy API for Data Science"
  app_type        = "non_interactive"
  is_first_party  = true
  oidc_conformant = true
  
  # Grant types
  grant_types = [
    "client_credentials"
  ]
  
  # JWT settings
  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
    secret_encoded      = false
  }
  
  # Refresh token settings
  refresh_token {
    expiration_type            = "non-expiring"
    leeway                     = 0
    infinite_token_lifetime    = true
    infinite_idle_token_lifetime = true 
    token_lifetime             = 31557600
    idle_token_lifetime        = 2592000
    rotation_type              = "non-rotating"
  }
  
  # Additional settings
  is_token_endpoint_ip_header_trusted = false
  sso_disabled                        = false
  cross_origin_auth                   = false
  custom_login_page_on                = true
}

# Configure client credentials to access the client_secret
# Note: Your Terraform Management API client needs the "read:client_keys" scope
resource "auth0_client_credentials" "express_app" {
  client_id = auth0_client.express_app.id
  authentication_method = "client_secret_post"
}

# Create Auth0 Application (Regular Web Application with Basic Auth)
resource "auth0_client" "web_app_basic" {
  name            = "Web Application with Basic Auth"
  app_type        = "regular_web"
  is_first_party  = true
  oidc_conformant = true
  
  # Callback URLs
  callbacks = ["http://localhost:3000/callback"]
  
  # Allowed logout URLs
  allowed_logout_urls = ["http://localhost:3000"]
  
  # Allowed web origins
  web_origins = ["http://localhost:3000"]
  
  # Grant types
  grant_types = [
    "authorization_code",
    "refresh_token"
  ]
  
  # JWT settings
  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
    secret_encoded      = false
  }
  
  # Refresh token settings
  refresh_token {
    expiration_type              = "expiring"
    leeway                       = 0
    token_lifetime               = 2592000
    idle_token_lifetime          = 1296000
    infinite_token_lifetime      = false
    infinite_idle_token_lifetime = false
    rotation_type                = "rotating"
  }
  
  # Additional settings
  is_token_endpoint_ip_header_trusted = false
  sso_disabled                        = false
  cross_origin_auth                   = false
}

# Configure client credentials with Basic authentication method
resource "auth0_client_credentials" "web_app_basic" {
  client_id = auth0_client.web_app_basic.id
  authentication_method = "client_secret_basic"
}


# Create Auth0 Application (Regular Web Application with Basic Auth)
resource "auth0_client" "web_app_basic_2" {
  name            = "Web Application with Basic Auth"
  app_type        = "regular_web"
  is_first_party  = true
  oidc_conformant = true
  
  # Callback URLs
  callbacks = ["http://localhost:3000/callback"]
  
  # Allowed logout URLs
  allowed_logout_urls = ["http://localhost:3000"]
  
  # Allowed web origins
  web_origins = ["http://localhost:3000"]
  
  # Grant types
  grant_types = [
    "authorization_code",
    "refresh_token"
  ]
  
  # JWT settings
  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
    secret_encoded      = false
  }
  
  # Refresh token settings
  refresh_token {
    expiration_type              = "expiring"
    leeway                       = 0
    token_lifetime               = 2592000
    idle_token_lifetime          = 1296000
    infinite_token_lifetime      = false
    infinite_idle_token_lifetime = false
    rotation_type                = "rotating"
  }
  
  # Additional settings
  is_token_endpoint_ip_header_trusted = false
  sso_disabled                        = false
  cross_origin_auth                   = false
}

# Configure client credentials with Basic authentication method
resource "auth0_client_credentials" "web_app_basic_2" {
  client_id = auth0_client.web_app_basic.id
  authentication_method = "client_secret_basic"
}