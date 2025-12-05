# Layered Deployment - Application Layer
# Uses the _app orchestration module to deploy all application components
#
# IMPORTANT: Deploy infrastructure layer first and note the name_suffix output
# The name_suffix is required to link this layer to the infrastructure

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

# Generate current SAS token to validate against provided token
data "azurerm_storage_account_sas" "validation" {
  connection_string = data.azurerm_storage_account.this.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = false
    queue = false
    table = false
    file  = true
  }

  start  = "2025-01-01T00:00:00Z"
  expiry = "2028-01-01T00:00:00Z"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# Get Log Analytics workspace (if monitoring is enabled)
data "azurerm_log_analytics_workspace" "this" {
  count               = var.log_analytics_workspace_name != "" ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

# Get Application Insights (if monitoring is enabled)
data "azurerm_application_insights" "this" {
  count               = var.app_insights_name != "" ? 1 : 0
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
}

locals {
  # Map subnet names from infrastructure layer to _app module expectations
  # New subnet structure per architecture diagram:
  # - presentation: App Services (AD, DS, SM)
  # - data: SQL, Redis, Storage (private endpoints, not used by app layer)
  # - aci: Stream Host (Azure Container Instances)
  # - processing: AI services (reserved for future use)
  subnet_names = var.vnet_name != "" && var.subnet_names != null ? {
    presentation = var.subnet_names.presentation
    data         = var.subnet_names.data
    aci          = var.subnet_names.aci
    processing   = var.subnet_names.processing
  } : null

  # Validate SAS token matches current storage account token
  current_sas_token  = data.azurerm_storage_account_sas.validation.sas
  provided_sas_token = var.storage_sas_token
  sas_tokens_match   = local.current_sas_token == local.provided_sas_token
}

module "applications" {
  source = "../../../_app"

  # ============================================================================
  # CORE CONFIGURATION
  # ============================================================================

  company_name = var.company_name
  name_suffix  = var.name_suffix

  # ============================================================================
  # INFRASTRUCTURE REFERENCES
  # ============================================================================

  resource_group_name     = var.resource_group_name
  resource_group_location = data.azurerm_resource_group.this.location
  storage_account_name    = var.storage_account_name
  storage_sas_token       = var.storage_sas_token # Will be auto-generated if empty
  sql_server_fqdn         = var.sql_server_fqdn

  # Service Plan Names
  ad_service_plan_name = var.ad_service_plan_name
  ds_service_plan_name = var.ds_service_plan_name
  sm_service_plan_name = var.sm_service_plan_name
  ai_service_plan_name = var.ai_service_plan_name

  # Key Vault Names
  ad_key_vault_name = var.ad_key_vault_name
  ds_key_vault_name = var.ds_key_vault_name
  sm_key_vault_name = var.sm_key_vault_name
  ai_key_vault_name = var.ai_key_vault_name != "" ? var.ai_key_vault_name : ""

  # SM Specific Key Vault Requirements
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  key_vault_certificate_pfx_blob = ""

  # Database IDs (always empty in layered - databases created by infrastructure layer)
  sm_database_id = ""
  ad_database_id = ""
  ds_database_id = ""
  ai_database_id = ""

  # ============================================================================
  # CREDENTIALS & SECRETS
  # ============================================================================

  # Container Registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.acr_username != ""

  # Database Authentication Mode
  enable_sql_aad_auth = var.enable_sql_aad_auth

  # App Database Managed Identities (from infrastructure layer, required when enable_sql_aad_auth = true)
  sm_db_managed_identity_name = var.sm_db_managed_identity_name
  sm_db_aad_client_id         = var.sm_db_aad_client_id
  ad_db_managed_identity_name = var.ad_db_managed_identity_name
  ad_db_aad_client_id         = var.ad_db_aad_client_id
  ds_db_managed_identity_name = var.ds_db_managed_identity_name
  ds_db_aad_client_id         = var.ds_db_aad_client_id
  ai_db_managed_identity_name = var.ai_db_managed_identity_name
  ai_db_aad_client_id         = var.ai_db_aad_client_id

  # Database Credentials (not used when enable_sql_aad_auth = true)
  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password

  # Custom Database Names
  sm_database_name = var.sm_database_name
  ad_database_name = var.ad_database_name
  ds_database_name = var.ds_database_name
  ai_database_name = var.ai_database_name

  # Application Admin Credentials
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password
  ad_encryption_key      = var.ad_encryption_key

  # ============================================================================
  # APPLICATION CONFIGURATION
  # ============================================================================

  imageversion       = var.imageversion
  is_evaluation_mode = var.is_evaluation_mode

  # Company Admin Details
  company_admin_first_name    = var.company_admin_first_name
  company_admin_last_name     = var.company_admin_last_name
  company_admin_email_address = var.company_admin_email_address

  # ============================================================================
  # FEATURE FLAGS
  # ============================================================================

  enable_ai                 = var.enable_ai
  create_stream_host        = var.create_stream_host
  enable_custom_domain      = var.enable_custom_domain
  dns_zone_name             = var.dns_zone_name
  enable_auto_scale         = var.enable_auto_scale
  redis_connection_string   = var.redis_connection_string
  enable_email_notification = var.enable_email_notification

  # ============================================================================
  # SMTP CONFIGURATION
  # ============================================================================

  smtp_server       = var.smtp_server
  smtp_from_address = var.smtp_from_address
  smtp_username     = var.smtp_username
  smtp_password     = var.smtp_password
  smtp_port         = var.smtp_port
  smtp_enable_ssl   = var.smtp_enable_ssl

  # ============================================================================
  # SSO CONFIGURATION
  # ============================================================================

  sso_enabled             = var.sso_enabled
  sso_azure_ad_client_id  = var.sso_azure_ad_client_id
  sso_azure_ad_secret     = var.sso_azure_ad_secret
  sso_business_role_claim = var.sso_business_role_claim
  sso_azure_ad_tenant_id  = var.sso_azure_ad_tenant_id

  # ============================================================================
  # MONITORING
  # ============================================================================

  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_id       = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].workspace_id : ""
  log_analytics_primary_shared_key = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].primary_shared_key : ""
  app_insights_name                = var.app_insights_name

  # ============================================================================
  # NETWORKING
  # ============================================================================

  prod_networking_enabled     = var.prod_networking_enabled
  override_public_access      = var.override_public_access
  private_dns_zone_sites_name = var.private_dns_zone_sites_name
  vnet_name                   = var.vnet_name
  subnet_names                = local.subnet_names

  # ============================================================================
  # RBAC CONFIGURATION
  # ============================================================================

  enable_rbac_authorization = var.enable_rbac_authorization

  # ============================================================================
  # CUSTOM RESOURCE NAMES (Optional)
  # ============================================================================

  name_ad_app_service        = var.name_ad_app_service
  name_ad_kv_identity        = var.name_ad_kv_identity
  name_ds_app_service        = var.name_ds_app_service
  name_ds_kv_identity        = var.name_ds_kv_identity
  name_sm_app_service        = var.name_sm_app_service
  name_sm_kv_identity        = var.name_sm_kv_identity
  name_ai_app_service        = var.name_ai_app_service
  name_ai_kv_identity        = var.name_ai_kv_identity
  name_stream_host_container = var.name_stream_host_container

  # ============================================================================
  # TAGS
  # ============================================================================

  common_tags = {
    "Billing" = var.billing_tag
    "Keep"    = var.keep_or_delete_tag
    "Layer"   = "Application"
  }

}