# Variables for layered application deployment


# Core configuration matching infrastructure
variable "company_name" {
  description = "Company name"
  type        = string
  default     = "xmproltd"
}

variable "name_suffix" {
  description = "Name suffix from infrastructure layer (e.g., sg01, sg02)"
  type        = string
}

# Infrastructure resource names
variable "resource_group_name" {
  description = "Name of the resource group created by infrastructure layer"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account created by infrastructure layer"
  type        = string
}

variable "sql_server_fqdn" {
  description = "FQDN of the SQL Server created by infrastructure layer"
  type        = string
  sensitive   = true
}

variable "storage_sas_token" {
  description = "Storage SAS token from infrastructure layer (optional - will be auto-generated if not provided)"
  type        = string
  default     = ""
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

# Container registry
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

# Database credentials (must match infrastructure)
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

# Application settings
variable "imageversion" {
  description = "Version tag for container images"
  type        = string
  default     = "latest"
}

variable "is_evaluation_mode" {
  description = "Enable evaluation mode"
  type        = bool
  default     = false
}


# SMTP configuration
variable "enable_email_notification" {
  description = "Enable SMTP email notifications"
  type        = bool
  default     = false
}

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

# AI service configuration
variable "enable_ai" {
  description = "Enable AI services"
  type        = bool
  default     = false
}

# Stream Host configuration
variable "create_stream_host" {
  description = "Create Stream Host App Service"
  type        = bool
  default     = false
}

# Custom domain configuration
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

variable "existing_dns_zone_resource_group" {
  description = "Resource group for existing DNS zone"
  type        = string
  default     = ""
}

# Tags
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

variable "enable_auto_scale" {
  description = "Enable auto-scaling with Redis distributed caching"
  type        = bool
  default     = false
}

variable "redis_connection_string" {
  description = "Redis connection string for auto-scaling (required when enable_auto_scale=true). Get from infrastructure outputs: terraform output -raw redis_primary_connection_string"
  type        = string
  default     = ""
  sensitive   = true
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
  description = "Azure AD tenant ID for SSO configuration"
  type        = string
  default     = ""
}

# Additional variables for company admin
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

variable "ai_key_vault_name" {
  description = "The name of the AI Key Vault from infrastructure layer (optional)"
  type        = string
  default     = ""
}

variable "ad_encryption_key" {
  description = "Encryption key for AD application. If not provided, will be auto-generated"
  type        = string
  sensitive   = true
  default     = ""
}