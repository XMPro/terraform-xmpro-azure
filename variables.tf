# Environment variables
variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = length(var.environment) <= 10
    error_message = "The environment variable must be less than 10 characters."
  }
}

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

variable "company_id" {
  description = "Company ID for resource naming and identification"
  type        = number
  default     = 2
  validation {
    condition     = var.company_id > 0
    error_message = "The company_id variable must be greater than 0."
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
  default     = ""
}

variable "company_admin_username" {
  description = "Username for the company administrator (format: firstname.lastname@companyname.onxmpro.com)"
  type        = string
  default     = ""
  validation {
    condition     = var.company_admin_username == "" || can(regex("^[a-zA-Z0-9._-]+\\.[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.onxmpro\\.com$", var.company_admin_username))
    error_message = "Username must follow the format: firstname.lastname@companyname.onxmpro.com or be empty string."
  }
}

# DNS configuration
variable "dns_zone_name" {
  description = "DNS zone name"
  type        = string
  default     = "jfmhnda.nonprod.xmprodev.com"
}

variable "enable_custom_domain" {
  description = "Whether to enable custom domain for the web apps"
  type        = bool
  default     = false

  validation {
    condition     = can(regex("^(true|false)$", tostring(var.enable_custom_domain)))
    error_message = "enable_custom_domain must be a boolean value"
  }
}

variable "use_existing_dns_zone" {
  description = "Whether to use an existing DNS zone"
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

# Auto Scale Configuration
variable "enable_auto_scale" {
  description = "Enable auto-scaling with Redis distributed caching"
  type        = bool
  default     = false
}

variable "redis_connection_string" {
  description = "Redis connection string for auto-scaling (e.g., 'your-redis.redis.cache.windows.net:6380,password=...,ssl=True,abortConnect=False'). Required when enable_auto_scale is true."
  type        = string
  default     = ""
  sensitive   = true
}

# Database credentials
variable "db_admin_username" {
  description = "Database admin username"
  type        = string
  sensitive   = true
  default     = "sqladmin"
}

variable "db_admin_password" {
  description = "Database admin password. Must be at least 8 characters and contain characters from three of the following categories: uppercase letters, lowercase letters, numbers, and non-alphanumeric characters."
  type        = string
  sensitive   = true
  default     = "P@ssw0rd1234!"
  validation {
    condition = (
      can(regex("^.{8,128}$", var.db_admin_password)) &&
      can(regex("[A-Z]", var.db_admin_password)) &&
      can(regex("[a-z]", var.db_admin_password)) &&
      can(regex("[0-9]", var.db_admin_password))
    )
    error_message = "Password must be 8-128 characters long and contain at least one uppercase letter, one lowercase letter, and one number. Consider also adding special characters for better security."
  }
}

# Existing Database Configuration
variable "use_existing_database" {
  description = "Whether to use an existing SQL Server and databases instead of creating new ones"
  type        = bool
  default     = false
}

variable "existing_sql_server_fqdn" {
  description = "Fully qualified domain name of the existing SQL Server (required when use_existing_database is true)"
  type        = string
  default     = ""
  validation {
    condition     = var.existing_sql_server_fqdn == "" || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?))*\\.(database\\.windows\\.net|sql\\.azuresynapse\\.net|database\\.azure\\.com|[a-zA-Z]{2,})$", var.existing_sql_server_fqdn))
    error_message = "existing_sql_server_fqdn must be a valid FQDN format. Examples: myserver.database.windows.net, myserver.sql.azuresynapse.net, myserver.database.azure.com, or custom domain like myserver.company.com"
  }
}

variable "existing_sm_product_id" {
  description = "Product ID for the existing Stream Manager (required when use_existing_database is true)"
  type        = string
  default     = ""
  validation {
    condition     = var.existing_sm_product_id == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.existing_sm_product_id))
    error_message = "existing_sm_product_id must be a valid GUID format."
  }
}

variable "existing_ad_product_id" {
  description = "Product ID for the existing Active Directory (required when use_existing_database is true)"
  type        = string
  default     = ""
  validation {
    condition     = var.existing_ad_product_id == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.existing_ad_product_id))
    error_message = "existing_ad_product_id must be a valid GUID format."
  }
}

variable "existing_ds_product_id" {
  description = "Product ID for the existing Data Service (required when use_existing_database is true)"
  type        = string
  default     = ""
  validation {
    condition     = var.existing_ds_product_id == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.existing_ds_product_id))
    error_message = "existing_ds_product_id must be a valid GUID format."
  }
}

variable "existing_ai_product_id" {
  description = "Product ID for the existing AI Service (required when use_existing_database is true and enable_ai is true)"
  type        = string
  default     = ""
  validation {
    condition     = var.existing_ai_product_id == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.existing_ai_product_id))
    error_message = "existing_ai_product_id must be a valid GUID format."
  }
}

variable "existing_ad_product_key" {
  description = "Product key for the existing Active Directory (required when use_existing_database is true)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_ds_product_key" {
  description = "Product key for the existing Data Service (required when use_existing_database is true)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_ai_product_key" {
  description = "Product key for the existing AI Service (required when use_existing_database is true and enable_ai is true)"
  type        = string
  default     = ""
  sensitive   = true
}

# Application credentials
variable "company_admin_password" {
  description = "Company admin password"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd1234!"
}

variable "site_admin_password" {
  description = "Site admin password"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd1234!"
}

# Container registry configuration
variable "is_private_registry" {
  description = "Whether to use private registry authentication for container images"
  type        = bool
  default     = false
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

variable "acr_url_product" {
  description = "Azure Container Registry URL for product images"
  type        = string
  default     = "xmpro.azurecr.io"
}

# Image version
variable "imageversion" {
  description = "Version of the Docker images to use"
  type        = string
  default     = "4.5.0.82-alpha-9db64dab7e"
}

# Local Access Configuration
variable "create_local_firewall_rule" {
  description = "Flag to determine whether to create a firewall rule for local access"
  type        = bool
  default     = true
}

# License API configuration
variable "license_api_url" {
  description = "URL for the license API endpoint"
  type        = string
  default     = "https://licensesnp.xmpro.com/api/license"
}

# App Service SKU configuration
variable "sm_service_plan_sku" {
  description = "SKU for the SM App Service plan"
  type        = string
  default     = "B2"
}

variable "ad_service_plan_sku" {
  description = "SKU for the AD App Service plan"
  type        = string
  default     = "B1"
}

variable "ds_service_plan_sku" {
  description = "SKU for the DS App Service plan"
  type        = string
  default     = "B1"
}

variable "ai_service_plan_sku" {
  description = "SKU for the AI App Service plan"
  type        = string
  default     = "B1"
}

variable "db_allow_all_ips" {
  description = "Flag to determine whether to allow all ips to connect to the database"
  type        = bool
  default     = false
}

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
  description = "SMTP password"
  type        = string
  sensitive   = true
  default     = "stored-in-keeper"
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

# Tagging configuration
variable "tags" {
  description = "A map of tags to apply to all resources. These will be merged with standard tags (Environment, Company, etc.)"
  type        = map(string)
  default = {
    "CreatedBy"      = "Terraform"
    "ManagedBy"      = "Platform Engineering"
    "Project"        = "XMPro Platform"
    "Keep_or_delete" = "Keep"
    "Billing"        = "Dev"
  }
}

# Stream Host Configuration
variable "stream_host_cpu" {
  description = "CPU allocation for the stream host container"
  type        = number
  default     = 1
  validation {
    condition     = var.stream_host_cpu >= 0.25 && var.stream_host_cpu <= 4
    error_message = "CPU must be between 0.25 and 4 cores."
  }
}

variable "stream_host_memory" {
  description = "Memory allocation (in GB) for the stream host container"
  type        = number
  default     = 4
  validation {
    condition     = var.stream_host_memory >= 0.5 && var.stream_host_memory <= 16
    error_message = "Memory must be between 0.5 and 16 GB."
  }
}

variable "stream_host_environment_variables" {
  description = "Additional environment variables for the stream host container"
  type        = map(string)
  default     = {}
}

variable "stream_host_variant" {
  description = "The Stream Host Docker image variant suffix. Options: '' (default, same as bookworm-slim), 'bookworm-slim', 'bookworm-slim-python3.12', 'alpine3.21'. Note: pip and SH_PIP_MODULES env vars are only available for bookworm-slim-python3.12 variant."
  type        = string
  default     = ""
  validation {
    condition = contains([
      "",
      "bookworm-slim",
      "bookworm-slim-python3.12",
      "alpine3.21"
    ], var.stream_host_variant)
    error_message = "The stream_host_variant must be one of: '' (default), 'bookworm-slim', 'bookworm-slim-python3.12', or 'alpine3.21'."
  }
}

# Evaluation Mode Configuration
variable "is_evaluation_mode" {
  description = "Whether to deploy with built-in license provisioning. If true, deploys licenses container with evaluation settings. If false (default), skips licenses container and user provides their own license management."
  type        = bool
  default     = false

  validation {
    condition     = can(regex("^(true|false)$", tostring(var.is_evaluation_mode)))
    error_message = "is_evaluation_mode must be a boolean value"
  }
}

# ASP.NET Core Environment Configuration
variable "aspnetcore_environment" {
  description = "ASP.NET Core environment setting"
  type        = string
  default     = "Development"
}

# SM Container Approach Variables
variable "sm_zip_download_url" {
  description = "Base domain for SM.zip download from storage account (e.g. 'download.nonprod.xmprodev.com')"
  type        = string
  default     = "download.nonprod.xmprodev.com"
}

variable "streamhost_download_base_url" {
  description = "Base URL for StreamHost downloads"
  type        = string
  default     = "https://download.app.xmpro.com/"
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

variable "ad_encryption_key" {
  description = "Encryption key for AD application to encrypt/decrypt server variables"
  type        = string
  sensitive   = true
  default     = ""
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

# Monitoring and Alerting Variables
variable "enable_alerting" {
  description = "Master switch to enable or disable all alerting resources"
  type        = bool
  default     = false
}

variable "enable_email_alerts" {
  description = "Enable email notifications for alerts"
  type        = bool
  default     = false
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive alert notifications"
  type        = list(string)
  default     = []
}

variable "enable_sms_alerts" {
  description = "Enable SMS notifications for alerts"
  type        = bool
  default     = false
}

variable "alert_phone_numbers" {
  description = "List of phone numbers to receive SMS alert notifications"
  type        = list(string)
  default     = []
}

variable "alert_phone_country_code" {
  description = "Country code for SMS alert phone numbers"
  type        = string
  default     = "1"
}

variable "enable_webhook_alerts" {
  description = "Enable webhook notifications for alerts"
  type        = bool
  default     = false
}

variable "alert_webhook_urls" {
  description = "List of webhook URLs to receive alert notifications"
  type        = list(string)
  default     = []
}

variable "enable_cpu_alerts" {
  description = "Enable CPU usage alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "cpu_alert_threshold" {
  description = "CPU usage percentage threshold for alerts"
  type        = number
  default     = 80
  validation {
    condition     = var.cpu_alert_threshold > 0 && var.cpu_alert_threshold <= 100
    error_message = "CPU alert threshold must be between 1 and 100 percent."
  }
}

variable "cpu_alert_severity" {
  description = "Severity level for CPU alerts (0-4, where 0 is critical)"
  type        = number
  default     = 2
  validation {
    condition     = var.cpu_alert_severity >= 0 && var.cpu_alert_severity <= 4
    error_message = "Alert severity must be between 0 (critical) and 4 (informational)."
  }
}

variable "enable_memory_alerts" {
  description = "Enable memory usage alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "memory_alert_threshold" {
  description = "Memory usage percentage threshold for alerts"
  type        = number
  default     = 80
  validation {
    condition     = var.memory_alert_threshold > 0 && var.memory_alert_threshold <= 100
    error_message = "Memory alert threshold must be between 1 and 100 percent."
  }
}

variable "memory_alert_severity" {
  description = "Severity level for memory alerts (0-4, where 0 is critical)"
  type        = number
  default     = 2
  validation {
    condition     = var.memory_alert_severity >= 0 && var.memory_alert_severity <= 4
    error_message = "Alert severity must be between 0 (critical) and 4 (informational)."
  }
}

variable "enable_container_restart_alerts" {
  description = "Enable container restart alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "enable_container_stop_alerts" {
  description = "Enable container stop alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "alert_window_size" {
  description = "The time window for metric alerts (ISO 8601 duration format)"
  type        = string
  default     = "PT5M"
}

variable "alert_evaluation_frequency" {
  description = "The evaluation frequency for metric alerts (ISO 8601 duration format)"
  type        = string
  default     = "PT1M"
}

