variable "company_name" {
  description = "Company name used for resource naming"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  type        = string
}

variable "databases" {
  description = "Map of database names to their resource IDs"
  type        = map(string)
}

variable "aad_sql_users_identity_id" {
  description = "ID of the AAD SQL users managed identity"
  type        = string
}

variable "aad_sql_users_client_id" {
  description = "Client ID of the AAD SQL users managed identity"
  type        = string
}

variable "sm_app_identity_name" {
  description = "Name of the SM app managed identity"
  type        = string
}

variable "ad_app_identity_name" {
  description = "Name of the AD app managed identity"
  type        = string
}

variable "ds_app_identity_name" {
  description = "Name of the DS app managed identity"
  type        = string
}

variable "ai_app_identity_name" {
  description = "Name of the AI app managed identity (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
