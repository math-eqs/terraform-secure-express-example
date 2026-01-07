# Main Terraform configuration file
# This configuration creates Auth0 applications and outputs credentials

# Local values for common configurations
locals {
  common_tags = {
    Environment = var.app_environment
    Application = var.app_name
    ManagedBy   = "terraform"
    CreatedAt   = formatdate("YYYY-MM-DD", timestamp())
  }
  
  # Naming convention
  name_prefix = "${replace(lower(var.app_name), " ", "-")}-${var.app_environment}"
}

# Note: The actual Auth0 resources are defined in auth0.tf
# This file serves as the main entry point and contains shared locals