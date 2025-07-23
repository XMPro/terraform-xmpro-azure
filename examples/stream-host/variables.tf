# Variables for Stream Host deployment
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

# Container registry settings
variable "is_private_registry" {
  description = "Whether to use private registry authentication for container images"
  type        = bool
  default     = false
}

variable "acr_url_product" {
  description = "The URL of the Azure Container Registry for product images"
  type        = string
  default     = "xmproacr.azurecr.io"
}

variable "acr_username" {
  description = "The username for the Azure Container Registry (only required for private images)"
  type        = string
  default     = ""
}

variable "acr_password" {
  description = "The password for the Azure Container Registry (only required for private images)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "imageversion" {
  description = "The version of the container image to use"
  type        = string
  default     = "4.5.0"
}

# Stream Host specific configuration
variable "ds_server_url" {
  description = "The URL of the Data Stream server (e.g., https://ds.example.com)"
  type        = string
  # No default - this must be provided by the user
}

variable "stream_host_collection_id" {
  description = "The collection ID for DS authentication"
  type        = string
  sensitive   = true
  # No default - this must be provided by the user
}

variable "stream_host_collection_secret" {
  description = "The collection secret for DS authentication"
  type        = string
  sensitive   = true
  # No default - this must be provided by the user
}

# Resource allocation
variable "stream_host_cpu" {
  description = "CPU allocation for the stream host container"
  type        = number
  default     = 1
  validation {
    condition     = var.stream_host_cpu >= 0.25 && var.stream_host_cpu <= 4
    error_message = "CPU must be between 0.25 and 4 cores."
  }
}

variable "stream_host_memory" {
  description = "Memory allocation (in GB) for the stream host container"
  type        = number
  default     = 4
  validation {
    condition     = var.stream_host_memory >= 0.5 && var.stream_host_memory <= 16
    error_message = "Memory must be between 0.5 and 16 GB."
  }
}

# Optional monitoring variables
variable "app_insights_connection_string" {
  description = "Application Insights connection string for telemetry"
  type        = string
  default     = null
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for container logs"
  type        = string
  default     = null
}

variable "log_analytics_primary_shared_key" {
  description = "Log Analytics workspace primary shared key"
  type        = string
  default     = null
  sensitive   = true
}

# Advanced configuration
variable "environment_variables" {
  description = "Additional environment variables for the stream host container"
  type        = map(string)
  default     = {}
}

variable "volumes" {
  description = "List of volumes to be mounted to the container. Supports both Azure File Share and secret volumes."
  type = list(object({
    name       = string
    mount_path = string
    read_only  = optional(bool, false)

    # Azure File Share volume (for persistent storage)
    share_name           = optional(string)
    storage_account_name = optional(string)
    storage_account_key  = optional(string)

    # Secret volume (for configuration files, certificates, etc.)
    secret = optional(map(string))
  }))
  default = []
}

# Resource tagging
variable "billing_tag" {
  description = "Tag for billing purposes"
  type        = string
  default     = "engineering"
}

variable "keep_or_delete_tag" {
  description = "Tag to indicate if resources should be kept or deleted"
  type        = string
  default     = "delete"
}