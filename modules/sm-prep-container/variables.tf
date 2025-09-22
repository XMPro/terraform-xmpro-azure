# SM Zip Preparation Module Variables
variable "environment" {
  description = "Environment identifier (dev*, qa*, staging, prod, sm-test)"
  type        = string
  validation {
    condition     = can(regex("^(dev.*|qa.*|staging|prod|smsandbox|sandbox)$", var.environment))
    error_message = "Environment must start with 'dev' or 'qa', or be 'staging', 'prod', 'smsandbox', or 'sandbox'."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "company_name" {
  description = "Company identifier for resource naming"
  type        = string
  validation {
    condition     = length(var.company_name) <= 18
    error_message = "The company name must be 18 characters or less to ensure Azure resource name limits are not exceeded."
  }
}

# Storage configuration for container volumes
variable "storage_account_name" {
  description = "Name of the storage account for Azure file shares"
  type        = string
}

variable "storage_account_key" {
  description = "Access key for the storage account"
  type        = string
  sensitive   = true
}

variable "storage_share_id" {
  description = "ID of the Azure file share"
  type        = string
}

variable "share_name" {
  description = "Name of the Azure file share"
  type        = string
}

# SM.zip download configuration
variable "sm_zip_download_url" {
  description = "Base domain for SM.zip download (e.g. 'download.nonprod.xmprodev.com')"
  type        = string
  default     = "download.nonprod.xmprodev.com"
}

variable "release_version" {
  description = "Release version for deployment tracking"
  type        = string
  default     = "v4.5.0.79-alpha-bc640cf6a9"
}

# Application configuration
variable "azure_key_vault_name" {
  description = "Name of the Azure Key Vault for secrets"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
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
  description = "Azure AD tenant ID for SSO (optional, for guest user access)"
  type        = string
  default     = ""
}

# Container registry configuration
variable "acr_url_product" {
  description = "The URL of the Azure Container Registry for product images"
  type        = string
}

variable "acr_username" {
  description = "The username for accessing the Azure Container Registry"
  type        = string
}

variable "acr_password" {
  description = "The password for accessing the Azure Container Registry"
  type        = string
  sensitive   = true
}

variable "imageversion" {
  description = "The version of the container image to use"
  type        = string
}

variable "is_private_registry" {
  description = "Whether to use a private container registry"
  type        = bool
  default     = true
}