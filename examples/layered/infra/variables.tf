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

variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
}

variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
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