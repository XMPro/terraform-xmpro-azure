# Migration Helper - Variables
# The migrationhelper container performs one-shot URL/ServerVariable writes
# against the existing 4.4 SM/AD/DS databases so the in-place upgrade points
# at the new App Service URLs. Product IDs/keys discovery for the new app
# layer is handled separately via Key Vault data-source lookups (see
# examples/migration/app/main.tf) -- not by this container.

variable "location" {
  description = "The Azure location for the container instance"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "company_name" {
  description = "Company name used in resource naming"
  type        = string
}

variable "name_suffix" {
  description = "Unique suffix for resource naming"
  type        = string
}

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================

variable "sql_server_fqdn" {
  description = "FQDN of the existing SQL Server to connect to"
  type        = string
}

variable "db_admin_username" {
  description = "Database admin username for SQL authentication (used for all databases)"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "Database admin password for SQL authentication (used for all databases)"
  type        = string
  sensitive   = true
}

variable "sm_database_name" {
  description = "Name of the SM database"
  type        = string
  default     = "SM"
}

variable "ad_database_name" {
  description = "Name of the AD database"
  type        = string
  default     = "AD"
}

variable "ds_database_name" {
  description = "Name of the DS database"
  type        = string
  default     = "DS"
}

# ============================================================================
# APPLICATION URLS
# ============================================================================

variable "ad_url" {
  description = "Target URL for App Designer"
  type        = string
}

variable "ds_url" {
  description = "Target URL for Data Stream Designer"
  type        = string
}

variable "ai_url" {
  description = "Target URL for AI (empty string to skip)"
  type        = string
  default     = ""
}

variable "nb_url" {
  description = "Target URL for XMPro Notebook (empty string to skip)"
  type        = string
  default     = ""
}

# ============================================================================
# NETWORKING CONFIGURATION
# ============================================================================

variable "prod_networking_enabled" {
  description = "Enable production networking with VNet integration"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration (ACI subnet). Required when prod_networking_enabled = true."
  type        = string
  default     = null
}

# ============================================================================
# TAGS
# ============================================================================

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
