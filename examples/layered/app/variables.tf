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

# Database Credentials
variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
  default     = "xmpro"
}

variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
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
  description = "Encryption key for AD application. If not provided, will be auto-generated"
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
  default     = "4.5.3"
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
  description = "Enable auto-scaling with Redis distributed caching"
  type        = bool
  default     = false
}

variable "redis_connection_string" {
  description = "Redis connection string for auto-scaling. Required when enable_auto_scale=true"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_email_notification" {
  description = "Enable SMTP email notifications"
  type        = bool
  default     = false
}

# ============================================================================
# SMTP CONFIGURATION
# ============================================================================

variable "smtp_server" {
  description = "SMTP server address"
  type        = string
  default     = ""
}

variable "smtp_from_address" {
  description = "SMTP from address"
  type        = string
  default     = "noreply@xmpro.com"
}

variable "smtp_username" {
  description = "SMTP username"
  type        = string
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "smtp_port" {
  description = "SMTP port"
  type        = number
  default     = 587
}

variable "smtp_enable_ssl" {
  description = "Enable SSL for SMTP"
  type        = bool
  default     = true
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

variable "name_ad_identity" {
  description = "Custom name for AD Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ad_identity == null || try(length(var.name_ad_identity) >= 3 && length(var.name_ad_identity) <= 128, false)
    error_message = "AD Managed Identity name must be between 3 and 128 characters. Current length: ${var.name_ad_identity == null ? 0 : length(var.name_ad_identity)}"
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

variable "name_ds_identity" {
  description = "Custom name for DS Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ds_identity == null || try(length(var.name_ds_identity) >= 3 && length(var.name_ds_identity) <= 128, false)
    error_message = "DS Managed Identity name must be between 3 and 128 characters. Current length: ${var.name_ds_identity == null ? 0 : length(var.name_ds_identity)}"
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

variable "name_sm_identity" {
  description = "Custom name for SM Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_sm_identity == null || try(length(var.name_sm_identity) >= 3 && length(var.name_sm_identity) <= 128, false)
    error_message = "SM Managed Identity name must be between 3 and 128 characters. Current length: ${var.name_sm_identity == null ? 0 : length(var.name_sm_identity)}"
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

variable "name_ai_identity" {
  description = "Custom name for AI Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_ai_identity == null || try(length(var.name_ai_identity) >= 3 && length(var.name_ai_identity) <= 128, false)
    error_message = "AI Managed Identity name must be between 3 and 128 characters."
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
