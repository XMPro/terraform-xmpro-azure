variable "tenant_id" {
  description = "Azure tenant ID for Key Vault access policies"
  type        = string
}

variable "name_suffix" {
  description = "Random suffix to append to resource names"
  type        = string
}

variable "location" {
  description = "The Azure location where all resources in this module should be created"
  type        = string
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

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "companyname" {
  description = "Company name used in resource naming"
  type        = string
}

variable "db_connection_string" {
  description = "The connection string for the SM database"
  type        = string
  sensitive   = true
}

variable "db_admin_username" {
  description = "The admin username for the database"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "The admin password for the database"
  type        = string
  sensitive   = true
}

variable "company_admin_password" {
  description = "The company admin password for Service Management"
  type        = string
  sensitive   = true
}

variable "site_admin_password" {
  description = "The site admin password for Service Management"
  type        = string
  sensitive   = true
}

variable "imageversion" {
  description = "The version of the container image to use"
  type        = string
  default     = "latest"
}

variable "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  type        = string
}

variable "files_location" {
  description = "The location of the SM.zip file in the storage account"
  type        = string
  default     = "Files-4.4.19"
}

variable "storage_account_name" {
  description = "The name of the storage account containing the SM.zip file"
  type        = string
}

variable "storage_sas_token" {
  description = "SAS token for accessing the storage account file"
  type        = string
  sensitive   = true
  default     = ""
}

variable "sm_service_plan_name" {
  description = "Name of the existing SM service plan from infrastructure"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "sm_prep_container_id" {
  description = "Container group ID for SM zip preparation (creates implicit dependency)"
  type        = string
  default     = ""
}

variable "sm_key_vault_name" {
  description = "Name of the SM Key Vault to use for secrets and certificates"
  type        = string
}

variable "certificate_pfx_blob" {
  description = "The PFX blob containing both certificate and private key from Key Vault"
  type        = string
  sensitive   = true
}

variable "github_release_version" {
  description = "GitHub release version for versioned SM zip filename (e.g., v4.5.0.80-alpha-ede1ab6d70)"
  type        = string
}

# Networking variables
variable "virtual_network_subnet_id" {
  description = "The ID of the subnet for VNet integration"
  type        = string
  default     = null
}

variable "vnet_route_all_enabled" {
  description = "Should all outbound traffic be routed through the VNet"
  type        = bool
  default     = false
}

# Custom resource naming (optional)
variable "custom_app_service_name" {
  description = "Custom name for SM App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null
}

variable "custom_identity_name" {
  description = "Custom name for SM Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null
}


variable "keyvault_secrets_reader_role_name" {
  description = "Azure RBAC role name for reading Key Vault secrets"
  type        = string
  default     = "Key Vault Secrets User"
}

variable "keyvault_certificates_reader_role_name" {
  description = "Azure RBAC role name for reading Key Vault certificates"
  type        = string
  default     = "Key Vault Certificate User"
}
