# Existing Database Example - Application Variables

# Core Configuration
variable "company_name" {
  description = "Company name"
  type        = string
}

variable "name_suffix" {
  description = "Name suffix from infrastructure layer"
  type        = string
}

# Infrastructure References
variable "resource_group_name" {
  description = "Resource group name from infrastructure layer"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name from infrastructure layer"
  type        = string
}

variable "storage_sas_token" {
  description = "Storage SAS token from infrastructure layer"
  type        = string
  default     = ""
  sensitive   = true
}

# Existing Database Configuration (REQUIRED)
variable "existing_sql_server_fqdn" {
  description = "FQDN of existing SQL Server"
  type        = string
}

variable "existing_sm_product_id" {
  description = "Product ID from existing SM database"
  type        = string
}

variable "existing_ad_product_id" {
  description = "Product ID from existing AD database"
  type        = string
}

variable "existing_ds_product_id" {
  description = "Product ID from existing DS database"
  type        = string
}

variable "existing_ai_product_id" {
  description = "Product ID from existing AI database (if enable_ai = true)"
  type        = string
  default     = ""
}

variable "existing_ad_product_key" {
  description = "Product key from existing AD database"
  type        = string
  sensitive   = true
}

variable "existing_ds_product_key" {
  description = "Product key from existing DS database"
  type        = string
  sensitive   = true
}

variable "existing_ai_product_key" {
  description = "Product key from existing AI database (if enable_ai = true)"
  type        = string
  default     = ""
  sensitive   = true
}

# Database Credentials
variable "db_admin_username" {
  description = "Database admin username"
  type        = string
}

variable "db_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

# Database Names
variable "sm_database_name" {
  description = "SM database name"
  type        = string
  default     = "SM"
}

variable "ad_database_name" {
  description = "AD database name"
  type        = string
  default     = "AD"
}

variable "ds_database_name" {
  description = "DS database name"
  type        = string
  default     = "DS"
}

variable "ai_database_name" {
  description = "AI database name"
  type        = string
  default     = "AI"
}

# Service Plan Names
variable "ad_service_plan_name" {
  description = "AD App Service Plan name"
  type        = string
}

variable "ds_service_plan_name" {
  description = "DS App Service Plan name"
  type        = string
}

variable "sm_service_plan_name" {
  description = "SM App Service Plan name"
  type        = string
}

variable "ai_service_plan_name" {
  description = "AI App Service Plan name"
  type        = string
  default     = ""
}

# Key Vault Names
variable "ad_key_vault_name" {
  description = "AD Key Vault name"
  type        = string
}

variable "ds_key_vault_name" {
  description = "DS Key Vault name"
  type        = string
}

variable "sm_key_vault_name" {
  description = "SM Key Vault name"
  type        = string
}

variable "ai_key_vault_name" {
  description = "AI Key Vault name"
  type        = string
  default     = ""
}

# Container Registry
variable "acr_url_product" {
  description = "ACR URL"
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

# Application Admin
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
  description = "AD encryption key (from existing installation)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "company_admin_first_name" {
  description = "Company admin first name"
  type        = string
  default     = "Admin"
}

variable "company_admin_last_name" {
  description = "Company admin last name"
  type        = string
  default     = "User"
}

variable "company_admin_email_address" {
  description = "Company admin email"
  type        = string
  default     = ""
}

# Application Configuration
variable "imageversion" {
  description = "Container image version"
  type        = string
  default     = "4.5.3"
}

# Features
variable "enable_ai" {
  description = "Enable AI service"
  type        = bool
  default     = false
}

variable "create_stream_host" {
  description = "Create Stream Host"
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

# Monitoring
variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  type        = string
}

variable "app_insights_name" {
  description = "Application Insights name"
  type        = string
}

# RBAC
variable "enable_rbac_authorization" {
  description = "Enable RBAC for Key Vault"
  type        = bool
  default     = true
}
