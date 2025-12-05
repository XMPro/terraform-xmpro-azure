# Application Layer Variables
# Variables needed for application deployments

# Core Environment Variables
variable "company_id" {
  description = "Company ID for resource naming and identification"
  type        = number
  default     = 2
}

variable "company_name" {
  description = "Company name for resource naming"
  type        = string
  default     = "evaluation"
}

# Company Admin Configuration
variable "company_admin_first_name" {
  description = "First name of the company administrator"
  type        = string
  default     = "admin"
  validation {
    condition = (
      can(regex("^[A-Za-z0-9]([A-Za-z0-9 -]*[A-Za-z0-9])?$", trimspace(var.company_admin_first_name))) &&
      length(trimspace(var.company_admin_first_name)) >= 1 &&
      length(trimspace(var.company_admin_first_name)) <= 50
    )
    error_message = "First name must start and end with an alphanumeric character, may contain spaces or hyphens in the middle, and must be 1-50 characters long (after trimming whitespace). Special characters (except spaces and hyphens) are not allowed."
  }
}

variable "company_admin_last_name" {
  description = "Last name of the company administrator"
  type        = string
  default     = "user"
  validation {
    condition = (
      can(regex("^[A-Za-z0-9]([A-Za-z0-9 -]*[A-Za-z0-9])?$", trimspace(var.company_admin_last_name))) &&
      length(trimspace(var.company_admin_last_name)) >= 1 &&
      length(trimspace(var.company_admin_last_name)) <= 50
    )
    error_message = "Last name must start and end with an alphanumeric character, may contain spaces or hyphens in the middle, and must be 1-50 characters long (after trimming whitespace). Special characters (except spaces and hyphens) are not allowed."
  }
}

variable "company_admin_email_address" {
  description = "Email address of the company administrator"
  type        = string
  default     = ""
}

variable "company_admin_username" {
  description = "Username for the company administrator"
  type        = string
  default     = ""
}

# DNS configuration
variable "dns_zone_name" {
  description = "DNS zone name (from infrastructure layer)"
  type        = string
  default     = ""
}

variable "enable_custom_domain" {
  description = "Whether to enable custom domain for the web apps"
  type        = bool
  default     = false
}

# AI Service Configuration
variable "enable_ai" {
  description = "Whether to enable the AI service and database"
  type        = bool
  default     = false
}

# Redis Cache Configuration
variable "create_redis_cache" {
  description = "Whether Redis cache was created in infrastructure"
  type        = bool
  default     = false
}

variable "enable_auto_scale" {
  description = "Enable auto-scaling with Redis distributed caching"
  type        = bool
  default     = false
}

variable "redis_connection_string" {
  description = "Redis connection string for auto-scaling"
  type        = string
  default     = ""
  sensitive   = true
}

variable "redis_primary_connection_string" {
  description = "Primary Redis connection string from infrastructure"
  type        = string
  default     = ""
  sensitive   = true
}

# Database Configuration
variable "enable_sql_aad_auth" {
  description = "Enable Azure AD (AAD) authentication for AD and DS app services. SM always uses SQL authentication regardless of this setting (requires code changes - see Work Item #21949). Migration containers always use AAD auth."
  type        = bool
  default     = false
}

variable "db_admin_username" {
  description = "Database admin username (not used when enable_sql_aad_auth is true)"
  type        = string
  sensitive   = true
  default     = "sqladmin"
}

variable "db_admin_password" {
  description = "Database admin password (minimum 12 characters required when SQL authentication is used, not needed when enable_sql_aad_auth is true)"
  type        = string
  sensitive   = true
  default     = null
}

variable "use_existing_database" {
  description = "Whether using an existing database"
  type        = bool
  default     = false
}

variable "existing_sql_server_fqdn" {
  description = "FQDN of existing SQL Server"
  type        = string
  default     = ""
}

variable "existing_sm_product_id" {
  description = "Existing SM product ID"
  type        = string
  default     = ""
}

variable "existing_ad_product_id" {
  description = "Existing AD product ID"
  type        = string
  default     = ""
}

variable "existing_ds_product_id" {
  description = "Existing DS product ID"
  type        = string
  default     = ""
}

variable "existing_ai_product_id" {
  description = "Existing AI product ID"
  type        = string
  default     = ""
}

variable "existing_ad_product_key" {
  description = "Existing AD product key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_ds_product_key" {
  description = "Existing DS product key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_ai_product_key" {
  description = "Existing AI product key"
  type        = string
  default     = ""
  sensitive   = true
}

# Database Name Configuration
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

# Application credentials
variable "company_admin_password" {
  description = "Company admin password (minimum 12 characters required)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.company_admin_password) >= 12
    error_message = "Company admin password must be at least 12 characters long for security compliance."
  }
}

variable "site_admin_password" {
  description = "Site admin password (minimum 12 characters required)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.site_admin_password) >= 12
    error_message = "Site admin password must be at least 12 characters long for security compliance."
  }
}

# Container registry configuration
variable "is_private_registry" {
  description = "Whether to use private registry authentication for container images"
  type        = bool
  default     = false
}

variable "acr_username" {
  description = "Azure Container Registry username"
  type        = string
  sensitive   = true
  default     = ""
}

variable "acr_password" {
  description = "Azure Container Registry password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "acr_url_product" {
  description = "Azure Container Registry URL for product images"
  type        = string
  default     = "xmpro.azurecr.io"
}

# Image version
variable "imageversion" {
  description = "Version of the Docker images to use"
  type        = string
  default     = "4.5.3"
}

# License API configuration
variable "license_api_url" {
  description = "URL for the license API endpoint"
  type        = string
  default     = "https://licensesnp.xmpro.com/api/license"
}

# SMTP Configuration
variable "enable_email_notification" {
  description = "Whether to enable email notifications"
  type        = bool
  default     = false
}

variable "smtp_server" {
  description = "SMTP server address"
  type        = string
  default     = "smtp.example.com"
}

variable "smtp_from_address" {
  description = "SMTP from address"
  type        = string
  default     = "notifications@example.com"
}

variable "smtp_username" {
  description = "SMTP username"
  type        = string
  default     = "notifications@example.com"
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
  sensitive   = true
  default     = "stored-in-keeper"
}

variable "smtp_port" {
  description = "SMTP port"
  type        = number
  default     = 587
}

variable "smtp_enable_ssl" {
  description = "Whether to enable SSL for SMTP"
  type        = bool
  default     = true
}

# Security Headers Configuration
variable "enable_security_headers" {
  description = "Whether to enable security headers for AD and DS applications"
  type        = bool
  default     = true
}

# ASP.NET Core Environment Configuration
variable "aspnetcore_environment" {
  description = "ASP.NET Core environment setting"
  type        = string
  default     = "Development"
}

# Stream Host Configuration
variable "create_stream_host" {
  description = "Whether to create stream host container"
  type        = bool
  default     = true
}

variable "stream_host_cpu" {
  description = "CPU allocation for the stream host container"
  type        = number
  default     = 1
}

variable "stream_host_memory" {
  description = "Memory allocation (in GB) for the stream host container"
  type        = number
  default     = 4
}

variable "stream_host_environment_variables" {
  description = "Additional environment variables for the stream host container"
  type        = map(string)
  default     = {}
}

variable "stream_host_variant" {
  description = "The Stream Host Docker image variant suffix"
  type        = string
  default     = ""
}

# Evaluation Mode Configuration
variable "is_evaluation_mode" {
  description = "Whether to deploy with built-in license provisioning"
  type        = bool
  default     = false
}

# SM Container Approach Variables
variable "sm_zip_download_url" {
  description = "Base domain for SM.zip download from storage account"
  type        = string
  default     = "download.nonprod.xmprodev.com"
}

variable "streamhost_download_base_url" {
  description = "Base URL for StreamHost downloads"
  type        = string
  default     = "https://download.app.xmpro.com/"
}

# SSO Configuration Variables
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
  description = "Azure AD tenant ID for SSO"
  type        = string
  default     = ""
}

variable "ad_encryption_key" {
  description = "Encryption key for AD application server variables. If not provided, a 32-character alphanumeric string will be automatically generated"
  type        = string
  sensitive   = true
  default     = ""
}

# Infrastructure inputs (passed from infrastructure layer)
variable "resource_group_name" {
  description = "Resource group name from infrastructure layer"
  type        = string
}

variable "resource_group_location" {
  description = "Resource group location from infrastructure layer"
  type        = string
}

variable "sql_server_fqdn" {
  description = "SQL Server FQDN from infrastructure layer"
  type        = string
}


variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name from infrastructure layer (optional - for monitoring)"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID from infrastructure layer"
  type        = string
}

variable "log_analytics_primary_shared_key" {
  description = "Log Analytics primary shared key from infrastructure layer"
  type        = string
  sensitive   = true
}

variable "app_insights_name" {
  description = "Application Insights name from infrastructure layer (optional - for monitoring)"
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Storage account name from infrastructure layer"
  type        = string
}



variable "storage_sas_token" {
  description = "Optional SAS token from infrastructure layer. If not provided (empty string), will automatically generate one. Expected format: '?sv=2017-07-29&ss=f&srt=sco&sp=rl&se=2028-01-01T00:00:00Z&st=2025-01-01T00:00:00Z&spr=https&sig=...'"
  type        = string
  sensitive   = true
  default     = ""
}



variable "key_vault_certificate_pfx_blob" {
  description = "Key Vault certificate PFX blob from infrastructure layer"
  type        = string
  sensitive   = true
}

variable "name_suffix" {
  description = "Name suffix from infrastructure layer"
  type        = string
}

variable "common_tags" {
  description = "Common tags from infrastructure layer"
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

# Database IDs (from infrastructure layer)
variable "sm_database_id" {
  description = "SM database ID from infrastructure layer"
  type        = string
  default     = ""
}

variable "ad_database_id" {
  description = "AD database ID from infrastructure layer"
  type        = string
  default     = ""
}

variable "ds_database_id" {
  description = "DS database ID from infrastructure layer"
  type        = string
  default     = ""
}

variable "ai_database_id" {
  description = "AI database ID from infrastructure layer"
  type        = string
  default     = ""
}
# Key Vault Names from Infrastructure Layer
variable "ad_key_vault_name" {
  description = "The name of the AD Key Vault from infrastructure layer"
  type        = string
}

variable "ds_key_vault_name" {
  description = "The name of the DS Key Vault from infrastructure layer"
  type        = string
}

variable "sm_key_vault_name" {
  description = "The name of the SM Key Vault from infrastructure layer"
  type        = string
}

variable "ai_key_vault_name" {
  description = "The name of the AI Key Vault from infrastructure layer (optional)"
  type        = string
  default     = ""
}

# Service Plan Names from Infrastructure Layer
variable "ad_service_plan_name" {
  description = "The name of the AD Service Plan from infrastructure layer"
  type        = string
}

variable "ds_service_plan_name" {
  description = "The name of the DS Service Plan from infrastructure layer"
  type        = string
}

variable "sm_service_plan_name" {
  description = "The name of the SM Service Plan from infrastructure layer"
  type        = string
}

variable "ai_service_plan_name" {
  description = "The name of the AI Service Plan from infrastructure layer (optional)"
  type        = string
  default     = ""
}

# Networking variables (from infrastructure layer)
variable "prod_networking_enabled" {
  description = "Whether production networking is enabled (from infrastructure layer)"
  type        = bool
  default     = false
}

variable "override_public_access" {
  description = "Override to enable public access even when prod_networking_enabled is true (useful for testing private endpoints)"
  type        = bool
  default     = false
}

variable "private_dns_zone_sites_name" {
  description = "Private DNS zone name for App Services (e.g., privatelink.azurewebsites.net). Leave empty to skip DNS integration."
  type        = string
  default     = "privatelink.azurewebsites.net"
}

variable "vnet_name" {
  description = "VNet name from infrastructure layer (when networking is enabled)"
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
  default = {
    presentation = "presentation"
    data         = ""
    aci          = "aci"
    processing   = ""
  }
}

# ============================================================================
# CUSTOM RESOURCE NAMES (Optional)
# ============================================================================

# AD (App Designer) Resources
variable "name_ad_app_service" {
  description = "Custom name for AD App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null
}

variable "name_ad_kv_identity" {
  description = "Custom name for AD Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null
}

# DS (Data Stream Designer) Resources
variable "name_ds_app_service" {
  description = "Custom name for DS App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null
}

variable "name_ds_kv_identity" {
  description = "Custom name for DS Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null
}

# SM (Subscription Manager) Resources
variable "name_sm_app_service" {
  description = "Custom name for SM App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null
}

variable "name_sm_kv_identity" {
  description = "Custom name for SM Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null
}

# AI Resources
variable "name_ai_app_service" {
  description = "Custom name for AI App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null
}

variable "name_ai_kv_identity" {
  description = "Custom name for AI Key Vault Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null
}

# Stream Host Container
variable "name_stream_host_container" {
  description = "Custom name for Stream Host Container Instance (overrides default naming). Max 64 characters."
  type        = string
  default     = null
}

# ============================================================================
# RBAC ROLE NAMES (Optional - for custom Azure RBAC roles)
# ============================================================================

variable "keyvault_secrets_reader_role_name" {
  description = "Azure RBAC role name for reading Key Vault secrets. Use custom role name if your organization uses custom roles instead of built-in roles."
  type        = string
  default     = "Key Vault Secrets User"
}

variable "keyvault_certificates_reader_role_name" {
  description = "Azure RBAC role name for reading Key Vault certificates. Use custom role name if your organization uses custom roles instead of built-in roles."
  type        = string
  default     = "Key Vault Certificate User"
}

variable "enable_rbac_authorization" {
  description = "Enable Azure RBAC for Key Vault authorization instead of access policies"
  type        = bool
  default     = true
}

# ============================================================================
# APP DATABASE MANAGED IDENTITIES (from infrastructure layer, for AAD SQL auth)
# ============================================================================

variable "sm_db_managed_identity_name" {
  description = "Name of the SM database managed identity for resource assignment (from infrastructure layer, null if AAD auth disabled)"
  type        = string
  default     = null
}

variable "sm_db_aad_client_id" {
  description = "Client ID of the SM database managed identity for AAD authentication (from infrastructure layer, null if AAD auth disabled)"
  type        = string
  default     = null
}

variable "ad_db_managed_identity_name" {
  description = "Name of the AD database managed identity for resource assignment (from infrastructure layer, null if AAD auth disabled)"
  type        = string
  default     = null
}

variable "ad_db_aad_client_id" {
  description = "Client ID of the AD database managed identity for AAD authentication (from infrastructure layer, null if AAD auth disabled)"
  type        = string
  default     = null
}

variable "ds_db_managed_identity_name" {
  description = "Name of the DS database managed identity for resource assignment (from infrastructure layer, null if AAD auth disabled)"
  type        = string
  default     = null
}

variable "ds_db_aad_client_id" {
  description = "Client ID of the DS database managed identity for AAD authentication (from infrastructure layer, null if AAD auth disabled)"
  type        = string
  default     = null
}

variable "ai_db_managed_identity_name" {
  description = "Name of the AI database managed identity for resource assignment (from infrastructure layer, null if AAD auth disabled or AI disabled)"
  type        = string
  default     = null
}

variable "ai_db_aad_client_id" {
  description = "Client ID of the AI database managed identity for AAD authentication (from infrastructure layer, null if AAD auth disabled or AI disabled)"
  type        = string
  default     = null
}
