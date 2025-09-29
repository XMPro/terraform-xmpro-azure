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
  description = "Company name used in resource naming"
  type        = string
}

variable "acr_url_product" {
  description = "The URL of the Azure Container Registry for product images"
  type        = string
}

variable "is_private_registry" {
  description = "Whether to use private registry authentication for container images"
  type        = bool
  default     = false
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

variable "db_connection_string" {
  description = "The connection string for the DS database"
  type        = string
  sensitive   = true
}

variable "collection_name" {
  description = "The collection name for DS database migration"
  type        = string
  default     = "Default"
}

variable "collection_id" {
  description = "The collection ID for DS database migration (provided by main module)"
  type        = string
}

variable "collection_secret" {
  description = "The collection secret for DS database migration (provided by main module)"
  type        = string
  sensitive   = true
}

variable "imageversion" {
  description = "The version of the container image to use"
  type        = string
  default     = "4.5.0-alpha"
}

variable "ds_database_id" {
  description = "The ID of the DS database, used to create an implicit dependency"
  type        = string
}

variable "deployment_suffix" {
  description = "Random suffix for ensuring unique resource names across deployments"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}