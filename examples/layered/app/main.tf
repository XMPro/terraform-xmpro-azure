# Layered Deployment - Application Layer
# Uses local module source for development with latest changes
# This allows testing the separated application layer before publishing
#
# IMPORTANT: Deploy infrastructure layer first and note the name_suffix output
# The name_suffix is required to link this layer to the infrastructure

# Layered Deployment - Application Layer
# Uses the _app orchestration module to deploy all application components

# Get Azure tenant ID
data "azurerm_client_config" "current" {}

# Get resource group details
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Get storage account details
data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

module "applications" {
  source = "../../../_app"

  # Core configuration
  company_name = var.company_name
  name_suffix  = var.name_suffix

  # Infrastructure references
  resource_group_name     = var.resource_group_name
  resource_group_location = data.azurerm_resource_group.this.location
  storage_account_name    = var.storage_account_name
  storage_sas_token       = var.storage_sas_token  # Will be auto-generated if empty

  # Tags (removed - handled internally)
  common_tags = {
    "Billing" = var.billing_tag
    "Keep"    = var.keep_or_delete_tag
    "Layer"   = "Application"
  }

  # SQL Server
  sql_server_fqdn = var.sql_server_fqdn

  # Log Analytics from infrastructure
  log_analytics_workspace_id = ""
  log_analytics_primary_shared_key = ""

  # Service plan names from infrastructure (already exist)
  ad_service_plan_name = var.ad_service_plan_name
  ds_service_plan_name = var.ds_service_plan_name
  sm_service_plan_name = var.sm_service_plan_name
  ai_service_plan_name = var.ai_service_plan_name

  # Key Vault configuration
  ad_key_vault_name = var.ad_key_vault_name
  ds_key_vault_name = var.ds_key_vault_name
  sm_key_vault_name = var.sm_key_vault_name
  ai_key_vault_name = var.ai_key_vault_name != "" ? var.ai_key_vault_name : ""

  # SM specific Key Vault requirements
  tenant_id = data.azurerm_client_config.current.tenant_id
  key_vault_certificate_pfx_blob = ""

  # Container registry
  acr_url_product = var.acr_url_product
  acr_username    = var.acr_username
  acr_password    = var.acr_password
  is_private_registry = var.acr_username != ""

  # Database credentials
  db_admin_username      = var.db_admin_username
  db_admin_password      = var.db_admin_password
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password

  # Company admin details
  company_admin_first_name    = var.company_admin_first_name
  company_admin_last_name     = var.company_admin_last_name
  company_admin_email_address = var.company_admin_email_address

  # Application settings
  imageversion       = var.imageversion
  is_evaluation_mode = var.is_evaluation_mode

  # SMTP settings
  enable_email_notification = var.enable_email_notification
  smtp_server               = var.smtp_server
  smtp_from_address         = var.smtp_from_address
  smtp_username             = var.smtp_username
  smtp_password             = var.smtp_password
  smtp_port                 = var.smtp_port
  smtp_enable_ssl           = var.smtp_enable_ssl

  # Feature flags
  enable_ai = var.enable_ai
  enable_custom_domain = var.enable_custom_domain
  dns_zone_name        = var.dns_zone_name
  enable_auto_scale        = var.enable_auto_scale
  redis_connection_string  = var.redis_connection_string

  # SSO Configuration
  sso_enabled              = var.sso_enabled
  sso_azure_ad_client_id   = var.sso_azure_ad_client_id
  sso_azure_ad_secret      = var.sso_azure_ad_secret
  sso_business_role_claim  = var.sso_business_role_claim
  sso_azure_ad_tenant_id   = var.sso_azure_ad_tenant_id

  # AD Encryption Key (optional - auto-generated if not provided)
  ad_encryption_key        = var.ad_encryption_key

  # Database IDs (always empty in layered - databases created by infrastructure layer)
  sm_database_id = ""
  ad_database_id = ""
  ds_database_id = ""
  ai_database_id = ""

}