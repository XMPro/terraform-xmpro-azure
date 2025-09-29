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

variable "imageversion" {
  description = "The Docker image version to deploy"
  type        = string
  default     = "4.5.0.153-alpha-19b99d6711"
}

variable "enable_custom_domain" {
  description = "Enable custom domain for the application"
  type        = bool
  default     = false
}

# Existing database configuration
variable "use_existing_database" {
  description = "Whether to use existing SQL Server and databases instead of creating new ones"
  type        = bool
  default     = true
}

variable "existing_sql_server_fqdn" {
  description = "Fully qualified domain name of the existing SQL Server"
  type        = string
  default     = "existing-sql-server.database.windows.net"
}

variable "existing_sm_product_id" {
  description = "The product ID for SM, shared between modules when using existing database"
  type        = string
  default     = ""
}

variable "existing_ad_product_id" {
  description = "The product ID for AD, shared between modules when using existing database"
  type        = string
  default     = ""
}

variable "existing_ds_product_id" {
  description = "The product ID for DS, shared between modules when using existing database"
  type        = string
  default     = ""
}

variable "existing_ai_product_id" {
  description = "The product ID for AI, shared between modules when using existing database"
  type        = string
  default     = ""
}

variable "existing_ad_product_key" {
  description = "The product key for AD, shared between modules when using existing database"
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_ds_product_key" {
  description = "The product key for DS, shared between modules when using existing database"
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_ai_product_key" {
  description = "The product key for AI, shared between modules when using existing database"
  type        = string
  default     = ""
  sensitive   = true
}

# SMTP configuration for email notifications
variable "smtp_password" {
  description = "SMTP password for email notifications"
  type        = string
  sensitive   = true
  default     = "ExampleSmtpP@ssw0rd123!"
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
    "Billing"        = "Existing Database"
    "Purpose"        = "XMPro deployment with existing database"
  }
}

# AI Services Configuration
variable "enable_ai" {
  description = "Enable AI services in the deployment"
  type        = bool
  default     = false
}

# Evaluation mode flag
variable "is_evaluation_mode" {
  description = "Flag to indicate if the deployment is in evaluation mode"
  type        = bool
  default     = true
}