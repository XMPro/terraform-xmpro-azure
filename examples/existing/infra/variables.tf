# Existing Database Example - Infrastructure Variables

# Core Configuration
variable "company_name" {
  description = "Company name for resource naming"
  type        = string
}

variable "name_suffix" {
  description = "Unique suffix for resource naming (4-8 chars)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Existing Database Configuration (REQUIRED)
variable "existing_sql_server_fqdn" {
  description = "FQDN of the existing SQL Server (e.g., your-server.database.windows.net)"
  type        = string
}

variable "existing_sm_product_id" {
  description = "Product ID from existing Subscription Manager database"
  type        = string
}

variable "db_admin_username" {
  description = "Database admin username (must have access to existing databases)"
  type        = string
}

variable "db_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

# Database Names (must match existing databases)
variable "sm_database_name" {
  description = "Name of existing Subscription Manager database"
  type        = string
  default     = "SM"
}

variable "ad_database_name" {
  description = "Name of existing App Designer database"
  type        = string
  default     = "AD"
}

variable "ds_database_name" {
  description = "Name of existing Data Stream Designer database"
  type        = string
  default     = "DS"
}

variable "ai_database_name" {
  description = "Name of existing AI database (if enable_ai = true)"
  type        = string
  default     = "AI"
}

# App Service Plan Configuration
variable "ad_service_plan_sku" {
  description = "App Designer App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "ds_service_plan_sku" {
  description = "Data Stream Designer App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "sm_service_plan_sku" {
  description = "Subscription Manager App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "ai_service_plan_sku" {
  description = "AI Designer App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "app_service_plan_worker_count" {
  description = "Number of workers for App Service Plans"
  type        = number
  default     = 1
}

# Feature Flags
variable "enable_ai" {
  description = "Enable AI service"
  type        = bool
  default     = false
}

variable "create_redis_cache" {
  description = "Create Redis Cache for auto-scaling"
  type        = bool
  default     = false
}

# DNS Configuration
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

# Networking Configuration
variable "prod_networking_enabled" {
  description = "Enable VNet integration"
  type        = bool
  default     = false
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Subnet address prefixes"
  type = object({
    presentation = string
    data         = string
    aci          = string
    processing   = string
  })
  default = null
}

# RBAC Configuration
variable "enable_rbac_authorization" {
  description = "Enable Azure RBAC for Key Vault"
  type        = bool
  default     = true
}

variable "keyvault_admin_role_name" {
  description = "Key Vault admin role name"
  type        = string
  default     = "Key Vault Administrator"
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
