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
  default     = ""
}

variable "acr_password" {
  description = "The password for the Azure Container Registry (only required for private images)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_connection_string" {
  description = "The connection string for the AI database"
  type        = string
  sensitive   = true
}

variable "ad_url" {
  description = "The URL for the AD application"
  type        = string
}

variable "sm_url" {
  description = "The URL for the SM application"
  type        = string
}

variable "ds_url" {
  description = "The URL for the DS application"
  type        = string
}

variable "ai_url" {
  description = "The URL for the AI application"
  type        = string
}

variable "app_insights_connection_string" {
  description = "The connection string for Application Insights"
  type        = string
  sensitive   = true
}

# New variables for service plan
variable "service_plan_sku" {
  description = "The SKU of the App Service Plan"
  type        = string
  default     = "B1"
}

# New variables for web app
variable "docker_image_name" {
  description = "The name of the Docker image to use for the web app"
  type        = string
  default     = "ai:4.4.19-pr-2606"
}

variable "aspnetcore_environment" {
  description = "The ASP.NET Core environment to use"
  type        = string
  default     = "dev"
}

variable "aidbmigrate_container_id" {
  description = "The ID of the AI database migration container, used to create an implicit dependency"
  type        = string
}

variable "ai_product_id" {
  description = "Product ID for AI service xmidentity client configuration"
  type        = string
  default     = "b7be889b-01d3-4bd2-95c6-511017472ec8"
}

variable "ai_product_key" {
  description = "Product key for AI service xmidentity client configuration"
  type        = string
  sensitive   = true
  default     = "950ca93b-1ad9-514b-4263-4d3f510012e2"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking variables
variable "virtual_network_subnet_id" {
  description = "The ID of the subnet to integrate the app service with"
  type        = string
  default     = null
}

variable "vnet_route_all_enabled" {
  description = "Should all outbound traffic be routed through the VNET"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access to the App Service"
  type        = bool
  default     = true
}

variable "ai_key_vault_name" {
  description = "The name of the AI Key Vault from infrastructure layer"
  type        = string
}


variable "ai_service_plan_name" {
  description = "The name of the AI Service Plan from infrastructure layer"
  type        = string
}

# Custom resource naming (optional)
variable "custom_app_service_name" {
  description = "Custom name for AI App Service (overrides default naming). Max 60 characters."
  type        = string
  default     = null
}

variable "custom_identity_name" {
  description = "Custom name for AI Managed Identity (overrides default naming). Max 128 characters."
  type        = string
  default     = null
}

variable "keyvault_secrets_reader_role_name" {
  description = "Azure RBAC role name for reading Key Vault secrets"
  type        = string
  default     = "Key Vault Secrets User"
}
