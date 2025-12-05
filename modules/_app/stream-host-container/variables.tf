
variable "location" {
  description = "The Azure location where all resources in this module should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "company_name" {
  description = "Company name used in resource naming"
  type        = string
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

variable "imageversion" {
  description = "The version of the container image to use"
  type        = string
  default     = "5.0.0-alpha"
}

variable "stream_host_variant" {
  description = "The Stream Host Docker image variant suffix. Options: '' (default, same as bookworm-slim), 'bookworm-slim', 'bookworm-slim-python3.12', 'alpine3.21'"
  type        = string
  default     = ""
  validation {
    condition = contains([
      "",
      "bookworm-slim",
      "bookworm-slim-python3.12",
      "alpine3.21"
    ], var.stream_host_variant)
    error_message = "The stream_host_variant must be one of: '' (default), 'bookworm-slim', 'bookworm-slim-python3.12', or 'alpine3.21'."
  }
}

# Stream Host specific configuration
variable "ds_server_url" {
  description = "The URL of the Data Stream server (e.g., https://ds.example.com)"
  type        = string
  validation {
    condition     = can(regex("^https?://", var.ds_server_url))
    error_message = "The ds_server_url must be a valid HTTP/HTTPS URL."
  }
}

variable "stream_host_collection_id" {
  description = "The collection ID for DS authentication"
  type        = string
  sensitive   = true
}

variable "stream_host_collection_secret" {
  description = "The collection secret for DS authentication"
  type        = string
  sensitive   = true
}

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

# Monitoring integration
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

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_suffix" {
  description = "Suffix to append to resource names for uniqueness"
  type        = string
  default     = ""
}

# Custom resource naming (optional)
variable "custom_container_name" {
  description = "Custom name for Stream Host Container Instance (overrides default naming). Max 64 characters."
  type        = string
  default     = null
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
  description = "Subnet ID for VNet integration (processing subnet). Required when prod_networking_enabled = true."
  type        = string
  default     = null
}