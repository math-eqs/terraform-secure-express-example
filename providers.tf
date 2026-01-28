# Configure required providers
terraform {
  required_version = ">= 1.0"
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure Auth0 Provider
# This requires a Management API M2M application to be created manually first
# Or you can use the Auth0 CLI: auth0 apps create --name "Terraform Provider" --type m2m
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}