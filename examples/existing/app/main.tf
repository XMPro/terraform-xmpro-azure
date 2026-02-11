# Existing Database Example - Application Layer
# Use this when connecting to an existing SQL Server and databases
#
# IMPORTANT: Deploy infrastructure layer first using examples/existing/infra

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

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

data "azurerm_log_analytics_workspace" "this" {
  count               = var.log_analytics_workspace_name != "" ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

data "azurerm_application_insights" "this" {
  count               = var.app_insights_name != "" ? 1 : 0
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
}

module "applications" {
  source = "../../_app"

  # Core Configuration
  company_name = var.company_name
  name_suffix  = var.name_suffix

  # Infrastructure References
  resource_group_name     = var.resource_group_name
  resource_group_location = data.azurerm_resource_group.this.location
  storage_account_name    = var.storage_account_name
  storage_sas_token       = var.storage_sas_token

  # Existing Database Configuration
  use_existing_database    = true
  existing_sql_server_fqdn = var.existing_sql_server_fqdn
  sql_server_fqdn          = ""  # Not used when use_existing_database = true

  # Existing Product IDs/Keys
  existing_sm_product_id  = var.existing_sm_product_id
  existing_ad_product_id  = var.existing_ad_product_id
  existing_ds_product_id  = var.existing_ds_product_id
  existing_ai_product_id  = var.existing_ai_product_id
  existing_ad_product_key = var.existing_ad_product_key
  existing_ds_product_key = var.existing_ds_product_key
  existing_ai_product_key = var.existing_ai_product_key

  # Service Plan Names
  ad_service_plan_name = var.ad_service_plan_name
  ds_service_plan_name = var.ds_service_plan_name
  sm_service_plan_name = var.sm_service_plan_name
  ai_service_plan_name = var.ai_service_plan_name

  # Key Vault Names
  ad_key_vault_name = var.ad_key_vault_name
  ds_key_vault_name = var.ds_key_vault_name
  sm_key_vault_name = var.sm_key_vault_name
  ai_key_vault_name = var.ai_key_vault_name

  # SM Key Vault Requirements
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  key_vault_certificate_pfx_blob = ""

  # Database IDs (empty for existing)
  sm_database_id = ""
  ad_database_id = ""
  ds_database_id = ""
  ai_database_id = ""

  # Container Registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.acr_username != ""

  # Database Credentials
  enable_sql_aad_auth = false  # Existing databases use SQL auth
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password

  # Database Names
  sm_database_name = var.sm_database_name
  ad_database_name = var.ad_database_name
  ds_database_name = var.ds_database_name
  ai_database_name = var.ai_database_name

  # Application Admin Credentials
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password
  ad_encryption_key      = var.ad_encryption_key

  # Application Configuration
  imageversion       = var.imageversion
  is_evaluation_mode = false  # Existing databases are not evaluation

  # Company Admin Details
  company_admin_first_name    = var.company_admin_first_name
  company_admin_last_name     = var.company_admin_last_name
  company_admin_email_address = var.company_admin_email_address

  # Features
  enable_ai            = var.enable_ai
  create_stream_host   = var.create_stream_host
  enable_custom_domain = var.enable_custom_domain
  dns_zone_name        = var.dns_zone_name

  # Monitoring
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_id       = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].workspace_id : ""
  log_analytics_primary_shared_key = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].primary_shared_key : ""
  app_insights_name                = var.app_insights_name

  # RBAC
  enable_rbac_authorization = var.enable_rbac_authorization

  # Tags
  common_tags = {
    "Layer" = "Application"
  }
}
