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
  default     = "xmprononprod.azurecr.io"
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