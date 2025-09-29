variable "company_name" {
  description = "Company name for resource naming and identification"
  type        = string
}

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
  description = "The name of the resource group in which to create the monitoring resources"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# Log Analytics variables
variable "enable_log_analytics" {
  description = "Whether to create a Log Analytics workspace"
  type        = bool
  default     = true
}

variable "log_analytics_name" {
  description = "The name of the Log Analytics workspace. If not provided, a name will be generated."
  type        = string
  default     = ""
}

variable "log_analytics_sku" {
  description = "The SKU of the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "The number of days to retain logs in the Log Analytics workspace"
  type        = number
  default     = 30
}

# Application Insights variables
variable "enable_app_insights" {
  description = "Whether to create an Application Insights instance"
  type        = bool
  default     = true
}

variable "app_insights_name" {
  description = "The name of the Application Insights instance. If not provided, a name will be generated."
  type        = string
  default     = ""
}

variable "application_type" {
  description = "The type of Application Insights to create"
  type        = string
  default     = "web"
}

variable "enable_app_insights_telemetry" {
  description = "Whether to enable Application Insights telemetry collection"
  type        = bool
  default     = true
}

