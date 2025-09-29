# Variables for the local environment
# These variables allow customization for individual developer testing

# Core platform settings
variable "environment" {
  description = "The environment name for resource identification"
  type        = string
  default     = "sandbox"
}

variable "location" {
  description = "The Azure region for resources"
  type        = string
  default     = "southeastasia"
}

variable "company_name" {
  description = "Company name used in resource naming"
  type        = string
  default     = "xmprosbx"
}

# Database credentials
variable "db_admin_username" {
  description = "The admin username for the SQL server"
  type        = string
  default     = "xmadmin"
}

variable "db_admin_password" {
  description = "The admin password for the SQL server"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd1234!"
}

variable "company_admin_password" {
  description = "The company admin password for Service Management"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd1234!"
}

variable "site_admin_password" {
  description = "The site admin password for Service Management"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd1234!"
}

# Company Admin Configuration
variable "company_admin_first_name" {
  description = "First name of the company administrator"
  type        = string
  default     = "admin"
}

variable "company_admin_last_name" {
  description = "Last name of the company administrator"
  type        = string
  default     = "user"
}

variable "company_admin_email_address" {
  description = "Email address of the company administrator"
  type        = string
  default     = "admin@xmpro.com"
}

# Container registry settings
variable "acr_url_product" {
  description = "The URL of the Azure Container Registry for product images"
  type        = string
  default     = "xmpro.azurecr.io"
}

variable "acr_username" {
  description = "Azure Container Registry username (only required for private images)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "acr_password" {
  description = "Azure Container Registry password (only required for private images)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "is_private_registry" {
  description = "Whether the container registry is private (requires authentication)"
  type        = bool
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", tostring(var.is_private_registry)))
    error_message = "is_private_registry must be a boolean value. Note: When true, acr_username and acr_password must be provided."
  }
}

variable "imageversion" {
  description = "The Docker image version to deploy"
  type        = string
  default     = "4.5.3"
}

variable "enable_custom_domain" {
  description = "Enable custom domain for the application"
  type        = bool
  default     = false
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
  description = "SMTP password for email notifications"
  type        = string
  sensitive   = true
  default     = "ExampleSmtpP@ssw0rd123!"
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

# Tagging
variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    "CreatedBy"      = "Terraform"
    "ManagedBy"      = "Platform Engineering"
    "Project"        = "XMPro Platform"
    "Keep_or_delete" = "Keep"
    "Billing"        = "Dev"
    "Purpose"        = "Basic XMPro deployment example"
  }
}

# Evaluation mode flag
variable "is_evaluation_mode" {
  description = "Flag to indicate if the deployment is in evaluation mode"
  type        = bool
  default     = true
}

# Database Configuration
variable "db_sku_name" {
  description = "The SKU name for all SQL databases (e.g., Basic, S0, S1, S2, S3, P1, P2, P4)"
  type        = string
  default     = "Basic"
  validation {
    condition = contains([
      "Basic",
      "S0", "S1", "S2", "S3", "S4", "S6", "S7", "S9", "S12",
      "P1", "P2", "P4", "P6", "P11", "P15",
      "GP_Gen5_2", "GP_Gen5_4", "GP_Gen5_6", "GP_Gen5_8", "GP_Gen5_10", "GP_Gen5_12", "GP_Gen5_14", "GP_Gen5_16", "GP_Gen5_18", "GP_Gen5_20", "GP_Gen5_24", "GP_Gen5_32", "GP_Gen5_40", "GP_Gen5_80",
      "BC_Gen5_2", "BC_Gen5_4", "BC_Gen5_6", "BC_Gen5_8", "BC_Gen5_10", "BC_Gen5_12", "BC_Gen5_14", "BC_Gen5_16", "BC_Gen5_18", "BC_Gen5_20", "BC_Gen5_24", "BC_Gen5_32", "BC_Gen5_40", "BC_Gen5_80"
    ], var.db_sku_name)
    error_message = "Invalid db_sku_name. Must be one of: Basic, S0-S12, P1-P15, or General Purpose/Business Critical Gen5 SKUs. Common values: Basic, S0, S1, S2, S3, P1, P2, P4."
  }
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

variable "db_allow_all_ips" {
  description = "Whether to allow all IP addresses to access the database"
  type        = bool
  default     = false
}

variable "create_local_firewall_rule" {
  description = "Whether to create a firewall rule for your current IP address"
  type        = bool
  default     = false
}

# DNS Configuration
variable "dns_zone_name" {
  description = "The DNS zone name for custom domain (required when enable_custom_domain = true)"
  type        = string
  default     = ""
}

variable "use_existing_dns_zone" {
  description = "Whether to use an existing DNS zone"
  type        = bool
  default     = true
}

# Service Plan SKUs
variable "ad_service_plan_sku" {
  description = "The SKU for the AD App Service Plan"
  type        = string
  default     = "B1"
}

variable "ds_service_plan_sku" {
  description = "The SKU for the DS App Service Plan"
  type        = string
  default     = "B1"
}

variable "sm_service_plan_sku" {
  description = "The SKU for the SM App Service Plan"
  type        = string
  default     = "B2"
}

# Stream Host Configuration
variable "stream_host_cpu" {
  description = "CPU allocation for Stream Host container"
  type        = number
  default     = 1
}

variable "stream_host_memory" {
  description = "Memory allocation in GB for Stream Host container"
  type        = number
  default     = 4
}

variable "stream_host_environment_variables" {
  description = "Additional environment variables for Stream Host"
  type        = map(string)
  default     = {}
}

# Redis Cache Configuration
variable "create_redis_cache" {
  description = "Whether to create an Azure Redis Cache instance"
  type        = bool
  default     = false
}

# Auto Scale Configuration
variable "enable_auto_scale" {
  description = "Enable auto-scaling with Redis distributed caching"
  type        = bool
  default     = false
}

variable "redis_connection_string" {
  description = "Redis connection string for auto-scaling (e.g., 'your-redis.redis.cache.windows.net:6380,password=...,ssl=True,abortConnect=False')"
  type        = string
  default     = ""
  sensitive   = true
}

# Master Data Configuration
variable "create_masterdata" {
  description = "Whether to create the Master Data database"
  type        = bool
  default     = false
}

variable "masterdata_db_admin_username" {
  description = "The administrator username for the Master Data database (for application access)"
  type        = string
  default     = "masterdata_admin"
}

variable "masterdata_db_admin_password" {
  description = "The administrator password for the Master Data database (for application access)"
  type        = string
  sensitive   = true
  default     = ""
}

# AD Encryption Configuration
variable "ad_encryption_key" {
  description = "Encryption key for AD server variables (32 bytes base64 encoded). If not provided, will be auto-generated."
  type        = string
  sensitive   = true
  default     = ""
}

 