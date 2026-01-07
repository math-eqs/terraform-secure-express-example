# Create AWS Secrets Manager secret for Auth0 credentials
resource "aws_secretsmanager_secret" "auth0_credentials" {
  name                    = "${var.secret_name}-${var.app_environment}"
  description             = "Auth0 credentials for ${var.app_name} - ${var.app_environment}"
  recovery_window_in_days = 7
  
  tags = {
    Environment   = var.app_environment
    Application   = var.app_name
    ManagedBy     = "terraform"
    SecretType    = "auth0-credentials"
  }
}

# Store Auth0 application credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "auth0_credentials" {
  secret_id = aws_secretsmanager_secret.auth0_credentials.id
  
  secret_string = jsonencode({
    client_id     = auth0_client.express_app.client_id
    client_secret = auth0_client_credentials.express_app.client_secret
    domain        = var.auth0_domain
  })
  
  depends_on = [
    auth0_client.express_app,
    auth0_client_credentials.express_app
  ]
}
