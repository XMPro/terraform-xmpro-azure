variable "name_suffix" {
  description = "Random suffix to append to resource names"
  type        = string
}


variable "location" {
  description = "The Azure location where all resources in this module should be created"
  type        = string
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus",
      "westcentralus", "canadacentral", "canadaeast", "brazilsouth", "northeurope", "westeurope",
      "francecentral", "germanywestcentral", "norwayeast", "switzerlandnorth", "uksouth", "ukwest",
      "eastasia", "southeastasia", "australiaeast", "australiasoutheast", "centralindia", "southindia",
      "westindia", "japaneast", "japanwest", "koreacentral", "koreasouth"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "companyname" {
  description = "Company name used in resource naming"
  type        = string
}

variable "acr_url_product" {
  description = "The URL of the Azure Container Registry for product images"
  type        = string
}

variable "is_private_registry" {
  description = "Whether to use private registry authentication for container images"
  type        = bool
  default     = false
}

variable "acr_username" {
  description = "The username for the Azure Container Registry (only required for private images)"
  type        = string
  default     = ""
}

variable "acr_password" {
  description = "The password for the Azure Container Registry (only required for private images)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_connection_string" {
  description = "The connection string for the AD database"
  type        = string
  sensitive   = true
}

variable "ad_url" {
  description = "The URL for the AD application"
  type        = string
}

variable "sm_url" {
  description = "The URL for the SM application"
  type        = string
}

variable "ds_url" {
  description = "The URL for the DS application"
  type        = string
}

variable "ai_url" {
  description = "The URL for the AI application"
  type        = string
}

variable "app_insights_connection_string" {
  description = "The connection string for Application Insights"
  type        = string
  sensitive   = true
}

# New variables for service plan
variable "service_plan_sku" {
  description = "The SKU of the App Service Plan"
  type        = string
  default     = "B1"
}

# New variables for web app
variable "docker_image_name" {
  description = "The name of the Docker image to use for the web app"
  type        = string
  default     = "ad:4.4.19-pr-2606"
}

variable "aspnetcore_environment" {
  description = "The ASP.NET Core environment to use"
  type        = string
  default     = "dev"
}

variable "addbmigrate_container_id" {
  description = "The ID of the AD database migration container, used to create an implicit dependency"
  type        = string
  default     = null
}

# SMTP Configuration

variable "enable_email_notification" {
  description = "Whether to enable email notifications"
  type        = bool
  default     = true
}

variable "smtp_server" {
  description = "SMTP server address"
  type        = string
}

variable "smtp_from_address" {
  description = "SMTP from address"
  type        = string
}

variable "smtp_username" {
  description = "SMTP username"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
  sensitive   = true
}

variable "smtp_port" {
  description = "SMTP port"
  type        = number
  default     = 25
}

variable "smtp_enable_ssl" {
  description = "Whether to enable SSL for SMTP"
  type        = bool
  default     = true
}

# Security Headers Configuration
variable "enable_security_headers" {
  description = "Whether to enable security headers for AD application"
  type        = bool
  default     = true
}

variable "ad_product_id" {
  description = "The product ID for AD"
  type        = string
}

variable "ad_product_key" {
  description = "The product key for AD"
  type        = string
  sensitive   = true
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

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "ad_encryption_key" {
  description = "Encryption key for AD application to encrypt/decrypt server variables"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ad_key_vault_name" {
  description = "The name of the AD Key Vault from infrastructure layer"
  type        = string
}

variable "ad_service_plan_name" {
  description = "The name of the AD Service Plan from infrastructure layer"
  type        = string
}

# Networking variables
variable "virtual_network_subnet_id" {
  description = "The ID of the subnet for VNet integration"
  type        = string
  default     = null
}

variable "vnet_route_all_enabled" {
  description = "Should all outbound traffic be routed through the VNet"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access to the App Service"
  type        = bool
  default     = true
}

# Custom resource naming (optional)
variable "custom_app_service_name" {
  description = "Custom name for AD App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null
}

variable "custom_identity_name" {
  description = "Custom name for AD Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null
}

# Existing identity (for AAD SQL auth - infrastructure creates identity)
variable "existing_identity_id" {
  description = "Resource ID of existing user-assigned managed identity (from infrastructure layer for AAD SQL auth). When provided, this identity will be used instead of creating a new one."
  type        = string
  default     = null
}

variable "existing_identity_client_id" {
  description = "Client ID of existing user-assigned managed identity (from infrastructure layer for AAD SQL auth)"
  type        = string
  default     = null
}

variable "keyvault_secrets_reader_role_name" {
  description = "Azure RBAC role name for reading Key Vault secrets"
  type        = string
  default     = "Key Vault Secrets User"
}

variable "tenant_id" {
  description = "Azure tenant ID for Key Vault access policies"
  type        = string
}

variable "enable_rbac_authorization" {
  description = "Enable Azure RBAC for Key Vault authorization instead of access policies"
  type        = bool
  default     = true
}

# ============================================================================
# NEW: MANAGED IDENTITY CONFIGURATION (KV + DB separation)
# ============================================================================

variable "create_identity" {
  description = "Whether to create a new managed identity. Set to false when using external KV+DB identities."
  type        = bool
  default     = true
}

variable "kv_identity_id" {
  description = "Resource ID of the Key Vault managed identity (from app layer) - always required"
  type        = string
  default     = null
}

variable "kv_identity_client_id" {
  description = "Client ID of the Key Vault managed identity - always required"
  type        = string
  default     = null
}

variable "kv_identity_principal_id" {
  description = "Principal ID (object ID) of the Key Vault managed identity for access policies"
  type        = string
  default     = null
}

variable "db_identity_id" {
  description = "Resource ID of the database managed identity (from infrastructure layer) - optional, only when AAD SQL auth enabled"
  type        = string
  default     = null
}

variable "db_identity_client_id" {
  description = "Client ID of the database managed identity for AAD authentication - optional"
  type        = string
  default     = null
}
