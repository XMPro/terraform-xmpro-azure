# Infrastructure Layer Variables
# Variables needed for infrastructure resources only

# Core Environment Variables
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "australiaeast"
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

variable "company_name" {
  description = "Company name for resource naming"
  type        = string
  default     = "evaluation"
  validation {
    condition     = length(var.company_name) <= 18
    error_message = "The company_name variable must be 18 characters or less."
  }
}

variable "name_suffix" {
  description = "Unique suffix for resource naming (e.g., 'sg01', 'sg02')"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{4,8}$", var.name_suffix))
    error_message = "Name suffix must be 4-8 lowercase alphanumeric characters."
  }
}

# App Service Plan Configuration
variable "ad_service_plan_sku" {
  description = "App Designer (AD) App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "ds_service_plan_sku" {
  description = "Data Stream Designer (DS) App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "sm_service_plan_sku" {
  description = "Subscription Manager (SM) App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "ai_service_plan_sku" {
  description = "AI Designer (AI) App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "app_service_plan_worker_count" {
  description = "Number of workers for App Service Plan"
  type        = number
  default     = 1
}

# Storage Account Configuration
# Monitoring Configuration
# DNS Configuration
variable "dns_zone_name" {
  description = "DNS zone name"
  type        = string
  default     = "jfmhnda.nonprod.xmprodev.com"
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
  description = "Whether to create an Azure Redis Cache instance"
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

# Database Configuration
variable "enable_sql_aad_auth" {
  description = "Enable Azure AD (AAD) authentication for SQL Server. When true, SQL authentication is disabled and Azure AD is used exclusively."
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
  description = "Whether to use an existing SQL Server and databases instead of creating new ones"
  type        = bool
  default     = false
}

variable "existing_sql_server_fqdn" {
  description = "Fully qualified domain name of the existing SQL Server"
  type        = string
  default     = ""
}

variable "existing_sm_product_id" {
  description = "Product ID for the existing Stream Manager"
  type        = string
  default     = ""
}

variable "create_local_firewall_rule" {
  description = "Flag to determine whether to create a firewall rule for local access"
  type        = bool
  default     = true
}

variable "db_allow_all_ips" {
  description = "Flag to determine whether to allow all ips to connect to the database"
  type        = bool
  default     = false
}

variable "db_sku_name" {
  description = "The SKU name for all SQL databases"
  type        = string
  default     = "Basic"
}

variable "db_max_size_gb" {
  description = "The maximum size in GB for all SQL databases"
  type        = number
  default     = 2
}

variable "db_collation" {
  description = "SQL collation for all databases"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "db_zone_redundant" {
  description = "Enable zone redundancy for databases (high availability)"
  type        = bool
  default     = false
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

# Master Data Configuration
variable "create_masterdata" {
  description = "Whether to create the Master Data database"
  type        = bool
  default     = false
}

variable "masterdata_db_admin_username" {
  description = "The administrator username for the Master Data database"
  type        = string
  default     = "masterdata_admin"
}

variable "masterdata_db_admin_password" {
  description = "The administrator password for the Master Data database (minimum 12 characters required when create_masterdata = true)"
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.masterdata_db_admin_password == "" || length(var.masterdata_db_admin_password) >= 12
    error_message = "Master Data database admin password must be at least 12 characters long when provided."
  }
}

# Networking Configuration
variable "prod_networking_enabled" {
  description = "Whether to enable production-grade networking with VNet and subnets"
  type        = bool
  default     = false
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for subnets (only required when prod_networking_enabled = true)"
  type = object({
    presentation = string # Subnet 1: App Services (AD, DS, SM) and Key Vaults
    data         = string # Subnet 2: SQL databases, Redis, Storage private endpoints
    aci          = string # Subnet 3: Stream Host (Azure Container Instances)
    processing   = string # Subnet 4: AI services (Azure Open AI, AI Search)
  })
  default = null
}

# ============================================================================
# RBAC ROLE NAMES (Optional - for custom Azure RBAC roles)
# ============================================================================

variable "keyvault_admin_role_name" {
  description = "Azure RBAC role name for Key Vault administration (Terraform principal). Use custom role name if your organization uses custom roles instead of built-in roles."
  type        = string
  default     = "Key Vault Administrator"
}

variable "enable_rbac_authorization" {
  description = "Enable Azure RBAC for Key Vault authorization instead of access policies. When true, uses Azure RBAC roles for permissions. When false, uses traditional access policies."
  type        = bool
  default     = true
}

# Tagging configuration
variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    "CreatedBy"      = "Terraform"
    "ManagedBy"      = "Platform Engineering"
    "Project"        = "XMPro Platform"
    "Keep_or_delete" = "Keep"
    "Billing"        = "Dev"
  }
}

