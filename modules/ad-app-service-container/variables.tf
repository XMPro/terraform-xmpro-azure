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
  description = "The connection string for the AD database"
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
  default     = "ad:4.4.19-pr-2606"
}

variable "aspnetcore_environment" {
  description = "The ASP.NET Core environment to use"
  type        = string
  default     = "dev"
}

variable "addbmigrate_container_id" {
  description = "The ID of the AD database migration container, used to create an implicit dependency"
  type        = string
  default     = null
}

# SMTP Configuration

variable "enable_email_notification" {
  description = "Whether to enable email notifications"
  type        = bool
  default     = true
}

variable "smtp_server" {
  description = "SMTP server address"
  type        = string
}

variable "smtp_from_address" {
  description = "SMTP from address"
  type        = string
}

variable "smtp_username" {
  description = "SMTP username"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
  sensitive   = true
}

variable "smtp_port" {
  description = "SMTP port"
  type        = number
  default     = 25
}

variable "smtp_enable_ssl" {
  description = "Whether to enable SSL for SMTP"
  type        = bool
  default     = true
}

variable "ad_product_id" {
  description = "The product ID for AD"
  type        = string
}

variable "ad_product_key" {
  description = "The product key for AD"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
