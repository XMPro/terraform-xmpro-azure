# Infrastructure Layer Variables

variable "company_name" {
  description = "Company name for resource naming"
  type        = string
}

variable "name_suffix" {
  description = "Predefined suffix for resource naming"
  type        = string
  default     = "001"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "enable_sql_aad_auth" {
  description = "Enable Azure AD (AAD) authentication for SQL Server. When true, SQL authentication is disabled and Azure AD is used exclusively."
  type        = bool
  default     = false
}

variable "db_admin_username" {
  description = "Database administrator username (not used when enable_sql_aad_auth is true)"
  type        = string
  default     = null
}

variable "db_admin_password" {
  description = "Database administrator password (not used when enable_sql_aad_auth is true)"
  type        = string
  sensitive   = true
  default     = null
}

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

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

variable "enable_app_insights" {
  description = "Enable Application Insights"
  type        = bool
  default     = true
}

variable "enable_log_analytics" {
  description = "Enable Log Analytics"
  type        = bool
  default     = false
}

variable "create_redis_cache" {
  description = "Create Redis Cache"
  type        = bool
  default     = false
}

variable "enable_alerting" {
  description = "Enable alerting"
  type        = bool
  default     = false
}

variable "create_masterdata" {
  description = "Create Master Data database"
  type        = bool
  default     = false
}

variable "enable_ai" {
  description = "Enable AI features"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Database SKU configuration
variable "db_sku_name" {
  description = "SKU name for the database"
  type        = string
  default     = "Basic"
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

# Database Firewall Configuration
variable "db_allow_all_ips" {
  description = "Allow all IPs to connect to the database"
  type        = bool
  default     = false
}

variable "create_local_firewall_rule" {
  description = "Create firewall rule for local access"
  type        = bool
  default     = true
}

# Master Data Database Variables
variable "masterdata_db_admin_username" {
  description = "Master Data database administrator username"
  type        = string
  default     = "mdadmin"
}

variable "masterdata_db_admin_password" {
  description = "Master Data database administrator password"
  type        = string
  default     = ""
  sensitive   = true
}

# Networking Variables
variable "prod_networking_enabled" {
  description = "Enable production-like networking with VNet, subnets, NSGs, and private endpoints"
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

# RBAC Configuration
variable "enable_rbac_authorization" {
  description = "Enable Azure RBAC for Key Vault authorization instead of access policies"
  type        = bool
  default     = true
}

variable "keyvault_admin_role_name" {
  description = "Azure RBAC role name for Key Vault administration (Terraform principal)"
  type        = string
  default     = "Key Vault Administrator"
}