# Variables for Auth0 Provider Configuration
variable "auth0_domain" {
  description = "Auth0 domain for the tenant"
  type        = string
}

variable "auth0_client_id" {
  description = "Auth0 Management API client ID (for Terraform provider)"
  type        = string
}

variable "auth0_client_secret" {
  description = "Auth0 Management API client secret (for Terraform provider)"
  type        = string
  sensitive   = true
}

# Application Configuration Variables
variable "app_name" {
  description = "Name for the Auth0 application"
  type        = string
  default     = "Express Demo App"
}

variable "app_environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "allowed_callback_urls" {
  description = "Allowed callback URLs for Auth0 application"
  type        = list(string)
  default     = ["http://localhost:3000/callback"]
}

variable "allowed_logout_urls" {
  description = "Allowed logout URLs for Auth0 application"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for Secrets Manager"
  type        = string
  default     = "us-east-1"
}

variable "secret_name" {
  description = "Name for the AWS Secrets Manager secret"
  type        = string
  default     = "auth0-app-credentials"
}