# Existing Database XMPro Platform Deployment Example
# This example demonstrates deploying XMPro platform using existing SQL Server and databases

module "xmpro_platform" {
  # Use the latest version from GitHub
  source = "github.com/XMPro/terraform-xmpro-azure"
  
  # For local development:
  # source = "../../"
  
  # For a specific version:
  # source = "github.com/XMPro/terraform-xmpro-azure?ref=v4.5.0"

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

  # Existing database configuration
  use_existing_database    = var.use_existing_database
  existing_sql_server_fqdn = var.existing_sql_server_fqdn

  # SMTP settings
  smtp_password = var.smtp_password
} 