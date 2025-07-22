# Basic XMPro Platform Deployment Example
# This example demonstrates a complete XMPro platform deployment on Azure

module "xmpro_platform" {
  # For production, use the GitHub source with a specific version:
  # source = "github.com/XMPro/terraform-xmpro-azure?ref=v5.0.0-alpha"
  
  # For local development:
  source = "../../"

  # Core settings - customize these for your local testing
  environment = var.environment
  location    = var.location

  # Company information
  company_name                = var.company_name
  company_admin_first_name    = var.company_admin_first_name
  company_admin_last_name     = var.company_admin_last_name
  company_admin_email_address = var.company_admin_email_address

  # Database credentials
  db_admin_username      = var.db_admin_username
  db_admin_password      = var.db_admin_password
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password

  # Docker registry
  acr_url_product = var.acr_url_product
  acr_username    = var.acr_username
  acr_password    = var.acr_password

  # Local-specific settings
  imageversion = var.imageversion

  # DNS configuration - customize for your testing
  enable_custom_domain = var.enable_custom_domain

  # SMTP settings
  smtp_password = "stored_in_keeper"
} 