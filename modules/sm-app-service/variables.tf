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

variable "service_plan_sku" {
  description = "The SKU for the App Service plan"
  type        = string
  default     = "B2"
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

variable "key_vault_id" {
  description = "ID of the Key Vault to use for secrets and certificates"
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

