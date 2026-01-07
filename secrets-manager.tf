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
    # Main application credentials
    client_id       = auth0_client.express_app.client_id
    client_secret   = auth0_client_credentials.express_app.client_secret
    domain          = var.auth0_domain
    api_identifier  = auth0_resource_server.express_api.identifier
    
    # Additional metadata
    app_name        = auth0_client.express_app.name
    environment     = var.app_environment
    created_at      = timestamp()
    
    # Callback URLs
    callback_urls   = auth0_client.express_app.callbacks
    logout_urls     = auth0_client.express_app.allowed_logout_urls
    
    # M2M credentials (if created)
    m2m_client_id     = var.app_environment == "prod" ? auth0_client.m2m_app[0].client_id : ""
    m2m_client_secret = var.app_environment == "prod" ? auth0_client_credentials.m2m_app[0].client_secret : ""
  })
  
  depends_on = [
    auth0_client.express_app,
    auth0_client_credentials.express_app,
    auth0_resource_server.express_api
  ]
}

# Create IAM policy for accessing the secret
resource "aws_iam_policy" "auth0_secrets_access" {
  name        = "Auth0SecretsAccess-${var.app_environment}"
  description = "Policy to access Auth0 credentials in Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.auth0_credentials.arn
      }
    ]
  })
  
  tags = {
    Environment = var.app_environment
    Application = var.app_name
    ManagedBy   = "terraform"
  }
}

# Create IAM role for the application (e.g., for EC2, ECS, Lambda)
resource "aws_iam_role" "app_role" {
  name = "${replace(lower(var.app_name), " ", "-")}-role-${var.app_environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
  
  tags = {
    Environment = var.app_environment
    Application = var.app_name
    ManagedBy   = "terraform"
  }
}

# Attach the secrets policy to the role
resource "aws_iam_role_policy_attachment" "app_secrets_access" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.auth0_secrets_access.arn
}

# Create instance profile for EC2 (if needed)
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${replace(lower(var.app_name), " ", "-")}-instance-profile-${var.app_environment}"
  role = aws_iam_role.app_role.name
  
  tags = {
    Environment = var.app_environment
    Application = var.app_name
    ManagedBy   = "terraform"
  }
}
