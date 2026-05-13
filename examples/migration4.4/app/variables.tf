# ============================================================================
# CORE CONFIGURATION
# ============================================================================

variable "company_name" {
  description = "Company name"
  type        = string
  default     = "xmproltd"
}

variable "name_suffix" {
  description = "Name suffix from infrastructure layer (e.g., sg01, sg02)"
  type        = string
}

# ============================================================================
# INFRASTRUCTURE REFERENCES (from infrastructure layer)
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group created by infrastructure layer"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account created by infrastructure layer"
  type        = string
}

variable "storage_sas_token" {
  description = "Storage SAS token from infrastructure layer (optional - will be auto-generated if not provided)"
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition     = var.storage_sas_token == "" || can(regex("^\\?sv=", var.storage_sas_token))
    error_message = "SAS token must start with '?' and include required parameters (e.g., '?sv=2021-06-08&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=...&st=...&spr=https&sig=...'). Leave empty to auto-generate."
  }
}

variable "sql_server_fqdn" {
  description = "FQDN of the SQL Server created by infrastructure layer"
  type        = string
  sensitive   = true
}

# Service Plan Names
variable "ad_service_plan_name" {
  description = "Name of the AD App Service Plan created by infrastructure layer"
  type        = string
}

variable "ds_service_plan_name" {
  description = "Name of the DS App Service Plan created by infrastructure layer"
  type        = string
}

variable "sm_service_plan_name" {
  description = "Name of the SM App Service Plan created by infrastructure layer"
  type        = string
}

variable "ai_service_plan_name" {
  description = "Name of the AI App Service Plan created by infrastructure layer"
  type        = string
  default     = ""
}

# Key Vault Names
variable "ad_key_vault_name" {
  description = "Name of the AD Key Vault created by infrastructure layer"
  type        = string
}

variable "ds_key_vault_name" {
  description = "Name of the DS Key Vault created by infrastructure layer"
  type        = string
}

variable "sm_key_vault_name" {
  description = "Name of the SM Key Vault created by infrastructure layer"
  type        = string
}

variable "ai_key_vault_name" {
  description = "The name of the AI Key Vault from infrastructure layer (optional)"
  type        = string
  default     = ""
}

# ============================================================================
# CREDENTIALS & SECRETS
# ============================================================================

# Container Registry
variable "acr_url_product" {
  description = "Azure Container Registry URL for product images"
  type        = string
  default     = "xmpro.azurecr.io"
}

variable "acr_username" {
  description = "ACR username"
  type        = string
  sensitive   = true
}

variable "acr_password" {
  description = "ACR password"
  type        = string
  sensitive   = true
}

# Database Authentication Mode
variable "enable_sql_aad_auth" {
  description = "Enable Azure AD (AAD) authentication for SQL Server. When true, containers use managed identity instead of SQL credentials."
  type        = bool
  default     = false
}

# App Database Managed Identities (from infrastructure layer, required when enable_sql_aad_auth = true)
variable "sm_db_managed_identity_name" {
  description = "Name of the SM database managed identity for resource assignment (from infrastructure layer, required when enable_sql_aad_auth is true)"
  type        = string
  default     = null
}

variable "sm_db_aad_client_id" {
  description = "Client ID of the SM database managed identity for AAD authentication (from infrastructure layer, required when enable_sql_aad_auth is true)"
  type        = string
  default     = null
}

variable "ad_db_managed_identity_name" {
  description = "Name of the AD database managed identity for resource assignment (from infrastructure layer, required when enable_sql_aad_auth is true)"
  type        = string
  default     = null
}

variable "ad_db_aad_client_id" {
  description = "Client ID of the AD database managed identity for AAD authentication (from infrastructure layer, required when enable_sql_aad_auth is true)"
  type        = string
  default     = null
}

variable "ds_db_managed_identity_name" {
  description = "Name of the DS database managed identity for resource assignment (from infrastructure layer, required when enable_sql_aad_auth is true)"
  type        = string
  default     = null
}

variable "ds_db_aad_client_id" {
  description = "Client ID of the DS database managed identity for AAD authentication (from infrastructure layer, required when enable_sql_aad_auth is true)"
  type        = string
  default     = null
}

variable "ai_db_managed_identity_name" {
  description = "Name of the AI database managed identity for resource assignment (from infrastructure layer, required when enable_sql_aad_auth is true and AI is enabled)"
  type        = string
  default     = null
}

variable "ai_db_aad_client_id" {
  description = "Client ID of the AI database managed identity for AAD authentication (from infrastructure layer, required when enable_sql_aad_auth is true and AI is enabled)"
  type        = string
  default     = null
}

# Database Credentials (not used when enable_sql_aad_auth = true)
variable "db_admin_username" {
  description = "Database administrator username (not used when enable_sql_aad_auth is true)"
  type        = string
  default     = "xmpro"
}

variable "db_admin_password" {
  description = "Database administrator password (not used when enable_sql_aad_auth is true)"
  type        = string
  sensitive   = true
  default     = null
}

# Custom Database Names
variable "sm_database_name" {
  description = "Name for the Subscription Manager database"
  type        = string
  default     = "SM"
}

variable "ad_database_name" {
  description = "Name for the App Designer database"
  type        = string
  default     = "AD"
}

variable "ds_database_name" {
  description = "Name for the Data Stream Designer database"
  type        = string
  default     = "DS"
}

variable "ai_database_name" {
  description = "Name for the AI Service database"
  type        = string
  default     = "AI"
}

# Application Admin Credentials
variable "company_admin_password" {
  description = "Company admin password"
  type        = string
  sensitive   = true
}

variable "site_admin_password" {
  description = "Site admin password"
  type        = string
  sensitive   = true
}

variable "ad_encryption_key" {
  description = "AD encryption key. Leave null/empty to let _app auto-generate one. Supply explicitly only if you need to match an existing key (e.g. continuity with an existing 4.4 deployment)."
  type        = string
  sensitive   = true
  default     = null
}

variable "ai_infrastructure_key" {
  description = "Infrastructure encryption key for the AI service. If not provided and AI is enabled, will be auto-generated"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# APPLICATION CONFIGURATION
# ============================================================================

variable "imageversion" {
  description = "Version tag for container images"
  type        = string
  default     = "4.6.1"
}

variable "sm_zip_download_url" {
  description = "Base domain for SM.zip download. Defaults to the public XMPro production download host."
  type        = string
  default     = "download.app.xmpro.com"
}

variable "is_evaluation_mode" {
  description = "Enable evaluation mode"
  type        = bool
  default     = false
}

# Company Admin Details
variable "company_admin_first_name" {
  description = "First name for company admin"
  type        = string
  default     = "John"
}

variable "company_admin_last_name" {
  description = "Last name for company admin"
  type        = string
  default     = "Doe"
}

variable "company_admin_email_address" {
  description = "Email address of the company administrator"
  type        = string
  default     = ""
}

# ============================================================================
# FEATURE FLAGS
# ============================================================================

variable "enable_ai" {
  description = "Enable AI services"
  type        = bool
  default     = false
}

variable "create_stream_host" {
  description = "Create Stream Host App Service"
  type        = bool
  default     = false
}

# Stream Connector Configuration
variable "enable_stream_connector_stream_host" {
  description = "Deploy a dedicated Stream Host for Stream Connector"
  type        = bool
  default     = false
}

variable "sc_stream_host_collection_id" {
  description = "Collection ID for SC stream host. Required when enable_stream_connector_stream_host = true."
  type        = string
  default     = ""
}

variable "sc_stream_host_collection_secret" {
  description = "Collection secret for SC stream host. Required when enable_stream_connector_stream_host = true."
  type        = string
  default     = ""
}

variable "enable_custom_domain" {
  description = "Enable custom domain"
  type        = bool
  default     = false
}

variable "dns_zone_name" {
  description = "DNS zone name"
  type        = string
  default     = ""
}

variable "enable_auto_scale" {
  description = "Enable Redis-backed auto-scaling. Defaults to false when null."
  type        = bool
  default     = null
}

variable "redis_connection_string" {
  description = "Redis connection string for auto-scaling. Required when enable_auto_scale = true."
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_email_notification" {
  description = "Enable email notification. Defaults to false when null."
  type        = bool
  default     = null
}

# ============================================================================
# SMTP CONFIGURATION
# ============================================================================
# All SMTP overrides accept null. When null AND use_existing_database = true,
# the value is read from the corresponding secret in sm_key_vault_name in the
# existing 4.4 Key Vault. Otherwise a safe default is used.

variable "smtp_server" {
  description = "SMTP server hostname. Defaults to empty string when null."
  type        = string
  default     = null
}

variable "smtp_from_address" {
  description = "SMTP from address. Defaults to noreply@xmpro.com when null."
  type        = string
  default     = null
}

variable "smtp_username" {
  description = "SMTP username. Defaults to empty string when null."
  type        = string
  default     = null
}

variable "smtp_password" {
  description = "SMTP password. Defaults to empty string when null. Supply via TF_VAR_smtp_password env var for security."
  type        = string
  default     = null
  sensitive   = true
}

variable "smtp_port" {
  description = "SMTP port. Defaults to 587 when null."
  type        = number
  default     = null
}

variable "smtp_enable_ssl" {
  description = "Enable SMTP SSL. Defaults to true when null."
  type        = bool
  default     = null
}

# ============================================================================
# SMTP OAUTH CONFIGURATION
# ============================================================================

variable "enable_email_oauth" {
  description = "Enable OAuth authentication for SMTP (required for Microsoft 365 after March 2026)"
  type        = bool
  default     = false
}

variable "email_oauth_token_endpoint" {
  description = "OAuth token endpoint URL (e.g., https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token)"
  type        = string
  default     = ""
}

variable "email_oauth_token_client_id" {
  description = "OAuth client ID (Azure AD Application ID)"
  type        = string
  default     = ""
}

variable "email_oauth_token_client_secret" {
  description = "OAuth client secret (Azure AD Application Secret)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "email_oauth_token_scope" {
  description = "OAuth token scope (use 'https://outlook.office365.com/.default' for Microsoft 365 SMTP)"
  type        = string
  default     = "https://outlook.office365.com/.default"
}

variable "email_oauth_token_method" {
  description = "OAuth token HTTP method"
  type        = string
  default     = "POST"
}

variable "email_oauth_token_grant_type" {
  description = "OAuth grant type"
  type        = string
  default     = "client_credentials"
}

# ============================================================================
# SSO CONFIGURATION
# ============================================================================

variable "sso_enabled" {
  description = "Enable SSO configuration for Azure AD"
  type        = bool
  default     = false
}

variable "sso_azure_ad_client_id" {
  description = "Azure AD application client ID for SSO"
  type        = string
  default     = ""
}

variable "sso_azure_ad_secret" {
  description = "Azure AD application secret for SSO"
  type        = string
  default     = ""
  sensitive   = true
}

variable "sso_business_role_claim" {
  description = "Azure AD claim name for business role synchronization"
  type        = string
  default     = ""
}

variable "sso_azure_ad_tenant_id" {
  description = "Azure AD tenant ID for SSO configuration"
  type        = string
  default     = ""
}

# ============================================================================
# MONITORING
# ============================================================================

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name from infrastructure layer (required)"
  type        = string

  validation {
    condition     = length(var.log_analytics_workspace_name) > 0
    error_message = "log_analytics_workspace_name is required."
  }
}

variable "app_insights_name" {
  description = "Application Insights name from infrastructure layer (required)"
  type        = string

  validation {
    condition     = length(var.app_insights_name) > 0
    error_message = "app_insights_name is required."
  }
}

# ============================================================================
# NETWORKING
# ============================================================================

variable "prod_networking_enabled" {
  description = "Enable production-like networking (VNet integration and private endpoints)"
  type        = bool
  default     = false
}

variable "vnet_name" {
  description = "Virtual Network name from infrastructure layer (for VNet integration)"
  type        = string
  default     = ""
}

variable "subnet_names" {
  description = "Subnet names from infrastructure layer (when networking is enabled)"
  type = object({
    presentation = string # Subnet 1: App Services (AD, DS, SM)
    data         = string # Subnet 2: SQL, Redis, Storage (private endpoints, not used by app layer)
    aci          = string # Subnet 3: Stream Host (Azure Container Instances)
    processing   = string # Subnet 4: AI services (reserved for future use)
  })
  default = null
}

variable "override_public_access" {
  description = "Override to enable public access even when prod_networking_enabled is true (for testing)"
  type        = bool
  default     = false
}

variable "private_dns_zone_sites_name" {
  description = "Private DNS zone name for App Services private endpoints (from infrastructure layer)"
  type        = string
  default     = ""
}

# ============================================================================
# CUSTOM RESOURCE NAMES (Optional)
# ============================================================================

# AD (App Designer) Resources
variable "name_ad_app_service" {
  description = "Custom name for AD App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ad_app_service == null || try(length(var.name_ad_app_service) >= 2 && length(var.name_ad_app_service) <= 60, false)
    error_message = "AD App Service name must be between 2 and 60 characters. Current length: ${var.name_ad_app_service == null ? 0 : length(var.name_ad_app_service)}"
  }
}

variable "name_ad_kv_identity" {
  description = "Custom name for AD Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ad_kv_identity == null || try(length(var.name_ad_kv_identity) >= 3 && length(var.name_ad_kv_identity) <= 128, false)
    error_message = "AD Key Vault Managed Identity name must be between 3 and 128 characters. Current length: ${var.name_ad_kv_identity == null ? 0 : length(var.name_ad_kv_identity)}"
  }
}

# DS (Data Stream Designer) Resources
variable "name_ds_app_service" {
  description = "Custom name for DS App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ds_app_service == null || try(length(var.name_ds_app_service) >= 2 && length(var.name_ds_app_service) <= 60, false)
    error_message = "DS App Service name must be between 2 and 60 characters. Current length: ${var.name_ds_app_service == null ? 0 : length(var.name_ds_app_service)}"
  }
}

variable "name_ds_kv_identity" {
  description = "Custom name for DS Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ds_kv_identity == null || try(length(var.name_ds_kv_identity) >= 3 && length(var.name_ds_kv_identity) <= 128, false)
    error_message = "DS Key Vault Managed Identity name must be between 3 and 128 characters. Current length: ${var.name_ds_kv_identity == null ? 0 : length(var.name_ds_kv_identity)}"
  }
}

# SM (Subscription Manager) Resources
variable "name_sm_app_service" {
  description = "Custom name for SM App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_sm_app_service == null || try(length(var.name_sm_app_service) >= 2 && length(var.name_sm_app_service) <= 60, false)
    error_message = "SM App Service name must be between 2 and 60 characters. Current length: ${var.name_sm_app_service == null ? 0 : length(var.name_sm_app_service)}"
  }
}

variable "name_sm_kv_identity" {
  description = "Custom name for SM Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_sm_kv_identity == null || try(length(var.name_sm_kv_identity) >= 3 && length(var.name_sm_kv_identity) <= 128, false)
    error_message = "SM Key Vault Managed Identity name must be between 3 and 128 characters. Current length: ${var.name_sm_kv_identity == null ? 0 : length(var.name_sm_kv_identity)}"
  }
}

# AI Resources
variable "name_ai_app_service" {
  description = "Custom name for AI App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ai_app_service == null || try(length(var.name_ai_app_service) >= 2 && length(var.name_ai_app_service) <= 60, false)
    error_message = "AI App Service name must be between 2 and 60 characters."
  }
}

variable "name_ai_kv_identity" {
  description = "Custom name for AI Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ai_kv_identity == null || try(length(var.name_ai_kv_identity) >= 3 && length(var.name_ai_kv_identity) <= 128, false)
    error_message = "AI Key Vault Managed Identity name must be between 3 and 128 characters."
  }
}

# Stream Host Container
variable "name_stream_host_container" {
  description = "Custom name for Stream Host Container Instance (overrides default naming). Max 64 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_stream_host_container == null || try(length(var.name_stream_host_container) >= 1 && length(var.name_stream_host_container) <= 63, false)
    error_message = "Stream Host Container name must be between 1 and 63 characters. Current length: ${var.name_stream_host_container == null ? 0 : length(var.name_stream_host_container)}"
  }
}

# ============================================================================
# ADDITIONAL STREAM HOSTS
# ============================================================================

variable "stream_hosts" {
  description = "Map of stream host configurations. Key is the name suffix (e.g., 'sh01', 'sh02'), value is the configuration object."
  type = map(object({
    collection_id         = string                    # Collection ID from DS (required)
    collection_secret     = string                    # Collection secret from DS (required)
    cpu                   = optional(number, 1)       # CPU cores (0.25-4)
    memory                = optional(number, 4)       # Memory in GB (0.5-16)
    imageversion          = optional(string, "")      # Container image version (empty = use main imageversion)
    variant               = optional(string, "")      # Image variant: "", "bookworm-slim-python3.12", "alpine3.21"
    environment_variables = optional(map(string), {}) # Additional environment variables
    volumes = optional(list(object({
      name                 = string
      mount_path           = string
      read_only            = optional(bool, false)
      share_name           = optional(string)
      storage_account_name = optional(string)
      storage_account_key  = optional(string)
      secret               = optional(map(string))
    })), [])
  }))
  default = {}
}

variable "stream_host_ds_server_url" {
  description = "URL of the Data Stream server for additional stream hosts (leave empty to use main DS URL)"
  type        = string
  default     = ""
}

# Alerting configuration for additional stream hosts
variable "stream_host_enable_alerting" {
  description = "Enable alerting for additional stream hosts"
  type        = bool
  default     = false
}

variable "stream_host_alert_email_addresses" {
  description = "Email addresses for stream host alerts"
  type        = list(string)
  default     = []
}

variable "stream_host_alert_webhook_urls" {
  description = "Webhook URLs for stream host alerts"
  type        = list(string)
  default     = []
}

variable "stream_host_enable_cpu_alerts" {
  description = "Enable CPU alerts for additional stream hosts"
  type        = bool
  default     = true
}

variable "stream_host_cpu_alert_threshold" {
  description = "CPU alert threshold for additional stream hosts"
  type        = number
  default     = 80
}

variable "stream_host_enable_memory_alerts" {
  description = "Enable memory alerts for additional stream hosts"
  type        = bool
  default     = true
}

variable "stream_host_memory_alert_threshold" {
  description = "Memory alert threshold for additional stream hosts"
  type        = number
  default     = 80
}

variable "stream_host_enable_restart_alerts" {
  description = "Enable container restart alerts for additional stream hosts"
  type        = bool
  default     = true
}

variable "stream_host_enable_stop_alerts" {
  description = "Enable container stop alerts for additional stream hosts"
  type        = bool
  default     = true
}

# ============================================================================
# RBAC CONFIGURATION
# ============================================================================

variable "enable_rbac_authorization" {
  description = "Enable Azure RBAC for Key Vault authorization instead of access policies"
  type        = bool
  default     = true
}

# ============================================================================
# TAGS
# ============================================================================

variable "keep_or_delete_tag" {
  description = "Tag to indicate if resources should be kept or deleted"
  type        = string
  default     = "keep"
}

variable "billing_tag" {
  description = "Billing tag for cost tracking"
  type        = string
  default     = "development"
}

# ============================================================================
# MIGRATION CONFIGURATION (4.4 -> 4.6 in-place upgrade)
# ============================================================================

variable "use_existing_database" {
  description = "Whether to use an existing SQL Server and databases (in-place 4.4 -> 4.6 upgrade) instead of creating new ones."
  type        = bool
  default     = true
}

variable "existing_sql_server_fqdn" {
  description = "FQDN of the existing 4.4 SQL Server. Required when use_existing_database = true."
  type        = string
  default     = null
}

# ----------------------------------------------------------------------------
# Existing 4.4 Product IDs / Keys (REQUIRED when use_existing_database = true)
# ----------------------------------------------------------------------------
# These are NOT auto-discovered. Run this query against your existing 4.4 SM
# database and supply the values in tfvars:
#
#   SELECT p.Name, LOWER(p.Id) AS product_id, pk.[Key] AS product_key
#   FROM Product p
#   LEFT JOIN ProductKey pk ON pk.ProductId = p.Id
#   WHERE p.Name IN ('XMPro','App Designer','Data Stream Designer','AI');
#
# Product IDs are lowercased automatically (4.6 OIDC audience claims are
# case-sensitive). Keys are passed through as-stored.

variable "existing_sm_product_id" {
  description = "SM ServerUUID (XMPro Product Id in SM.Product). Required when use_existing_database = true. Lowercased automatically."
  type        = string
  default     = null
}

variable "existing_ad_product_id" {
  description = "App Designer Product Id from SM.Product. Required when use_existing_database = true. Lowercased automatically."
  type        = string
  default     = null
}

variable "existing_ds_product_id" {
  description = "Data Stream Designer Product Id from SM.Product. Required when use_existing_database = true. Lowercased automatically."
  type        = string
  default     = null
}

variable "existing_ai_product_id" {
  description = "AI Product Id from SM.Product. Required when use_existing_database = true AND enable_ai = true. Lowercased automatically."
  type        = string
  default     = null
}

variable "existing_ad_product_key" {
  description = "App Designer Product Key from SM.ProductKey. Required when use_existing_database = true. Case-sensitive."
  type        = string
  default     = null
  sensitive   = true
}

variable "existing_ds_product_key" {
  description = "Data Stream Designer Product Key from SM.ProductKey. Required when use_existing_database = true. Case-sensitive."
  type        = string
  default     = null
  sensitive   = true
}

variable "existing_ai_product_key" {
  description = "AI Product Key from SM.ProductKey. Required when use_existing_database = true AND enable_ai = true. Case-sensitive."
  type        = string
  default     = null
  sensitive   = true
}

