variable "environment" {
  description = "The environment name for resource identification"
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

variable "company_name" {
  description = "The company name for license provisioning"
  type        = string
  default     = "Evaluation"
}

variable "is_private_registry" {
  description = "Whether to use private registry authentication for container images"
  type        = bool
  default     = false
}

variable "acr_url_product" {
  description = "The URL of the Azure Container Registry for product images"
  type        = string
}

variable "acr_username" {
  description = "The username for the Azure Container Registry (only required for private images)"
  type        = string
}

variable "acr_password" {
  description = "The password for the Azure Container Registry (only required for private images)"
  type        = string
  sensitive   = true
}

variable "sql_server_fqdn" {
  description = "The FQDN of the SQL server"
  type        = string
}

variable "db_admin_username" {
  description = "The admin username for the database"
  type        = string
}

variable "db_admin_password" {
  description = "The admin password for the database"
  type        = string
  sensitive   = true
}

variable "company_id" {
  description = "The company ID for license provisioning"
  type        = number
  default     = 2
}

variable "ad_product_id" {
  description = "The product ID for AD"
  type        = string
}

variable "ds_product_id" {
  description = "The product ID for DS"
  type        = string
}

variable "ai_product_id" {
  description = "The product ID for AI"
  type        = string
}

variable "license_api_url" {
  description = "The URL for the license API endpoint"
  type        = string
}

variable "sm_database_name" {
  description = "The name of the SM database"
  type        = string
  default     = "SM"
}

variable "imageversion" {
  description = "The version of the container image to use"
  type        = string
  default     = "5.0.0-alpha"
}

variable "smdbmigrate_container_id" {
  description = "The ID of the SM database migration container, used to create an implicit dependency"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "deployment_suffix" {
  description = "Random suffix for ensuring unique resource names across deployments"
  type        = string
}
