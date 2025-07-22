# Existing Database XMPro Platform Deployment Example
# This example demonstrates deploying XMPro platform using existing SQL Server and databases

module "xmpro_platform" {
  source = "XMPro/terraform-xmpro-azure"
  # For local development, use: source = "../../"

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

  # Local-specific settings
  imageversion = var.imageversion

  # DNS configuration - customize for your testing
  enable_custom_domain = var.enable_custom_domain

  # Existing database configuration
  use_existing_database              = var.use_existing_database
  existing_sql_server_name           = var.existing_sql_server_name
  existing_sql_server_resource_group = var.existing_sql_server_resource_group
  existing_database_names            = var.existing_database_names

  # SMTP settings
  smtp_password = "stored_in_keeper"
} 