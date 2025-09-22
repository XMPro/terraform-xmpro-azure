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

variable "use_existing_resource_group" {
  description = "Whether to use an existing resource group instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_resource_group_name" {
  description = "The name of the existing resource group to use (required if use_existing_resource_group is true)"
  type        = string
  default     = ""
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
  default     = "xmpro.azurecr.io"
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

variable "stream_host_variant" {
  description = "Stream Host Docker image variant. Options: '' (default/bookworm-slim), 'bookworm-slim-python3.12' (with Python support), 'alpine3.21' (lightweight). Python package env vars (SH_PIP_MODULES, PIP_REQUIREMENTS_PATH) only work with bookworm-slim-python3.12."
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

# Optional external monitoring variables (used when enable_monitoring = false)
variable "existing_app_insights_connection_string" {
  description = "External Application Insights connection string for telemetry (ignored when enable_monitoring = true)"
  type        = string
  default     = null
  sensitive   = true
}

variable "existing_log_analytics_workspace_id" {
  description = "External Log Analytics workspace ID for container logs (ignored when enable_monitoring = true)"
  type        = string
  default     = null
}

variable "existing_log_analytics_primary_shared_key" {
  description = "External Log Analytics workspace primary shared key (ignored when enable_monitoring = true)"
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

# Monitoring and Alerting Configuration
variable "enable_monitoring" {
  description = "Enable monitoring infrastructure (Application Insights, Log Analytics)"
  type        = bool
  default     = false
}

variable "enable_alerting" {
  description = "Enable alerting resources (requires Application Insights - either enable_monitoring = true or provide external_app_insights_id)"
  type        = bool
  default     = false
}

# External monitoring configuration (when enable_monitoring = false but enable_alerting = true)
variable "external_app_insights_id" {
  description = "External Application Insights ID for alerting (required when enable_alerting = true and enable_monitoring = false)"
  type        = string
  default     = null
}

variable "enable_email_alerts" {
  description = "Enable email notifications for alerts"
  type        = bool
  default     = false
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive alert notifications"
  type        = list(string)
  default     = []
}

variable "enable_sms_alerts" {
  description = "Enable SMS notifications for alerts"
  type        = bool
  default     = false
}

variable "alert_phone_numbers" {
  description = "List of phone numbers to receive SMS alert notifications"
  type        = list(string)
  default     = []
}

variable "alert_phone_country_code" {
  description = "Country code for SMS alert phone numbers"
  type        = string
  default     = "1"
}

variable "enable_webhook_alerts" {
  description = "Enable webhook notifications for alerts"
  type        = bool
  default     = false
}

variable "alert_webhook_urls" {
  description = "List of webhook URLs to receive alert notifications"
  type        = list(string)
  default     = []
}

# Stream Host Container Alerts
variable "enable_cpu_alerts" {
  description = "Enable CPU usage alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "cpu_alert_threshold" {
  description = "CPU usage percentage threshold for alerts"
  type        = number
  default     = 80
  validation {
    condition     = var.cpu_alert_threshold > 0 && var.cpu_alert_threshold <= 100
    error_message = "CPU alert threshold must be between 1 and 100 percent."
  }
}

variable "cpu_alert_severity" {
  description = "Severity level for CPU alerts (0-4, where 0 is critical)"
  type        = number
  default     = 2
  validation {
    condition     = var.cpu_alert_severity >= 0 && var.cpu_alert_severity <= 4
    error_message = "Alert severity must be between 0 (critical) and 4 (informational)."
  }
}

variable "enable_memory_alerts" {
  description = "Enable memory usage alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "memory_alert_threshold" {
  description = "Memory usage percentage threshold for alerts"
  type        = number
  default     = 80
  validation {
    condition     = var.memory_alert_threshold > 0 && var.memory_alert_threshold <= 100
    error_message = "Memory alert threshold must be between 1 and 100 percent."
  }
}

variable "memory_alert_severity" {
  description = "Severity level for memory alerts (0-4, where 0 is critical)"
  type        = number
  default     = 2
  validation {
    condition     = var.memory_alert_severity >= 0 && var.memory_alert_severity <= 4
    error_message = "Alert severity must be between 0 (critical) and 4 (informational)."
  }
}

variable "enable_container_restart_alerts" {
  description = "Enable container restart alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "enable_container_stop_alerts" {
  description = "Enable container stop alerts for Stream Host containers"
  type        = bool
  default     = false
}

variable "alert_window_size" {
  description = "The time window for metric alerts (ISO 8601 duration format)"
  type        = string
  default     = "PT5M"
}

variable "alert_evaluation_frequency" {
  description = "The evaluation frequency for metric alerts (ISO 8601 duration format)"
  type        = string
  default     = "PT1M"
}

# Tagging
variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    "CreatedBy"      = "Terraform"
    "ManagedBy"      = "Platform Engineering"
    "Project"        = "XMPro Platform"
    "Keep_or_delete" = "Keep"
    "Billing"        = "Stream Host"
    "Purpose"        = "Stream Host container deployment example"
  }
}

variable "log_analytics_quota" {
  description = "Log Analytics workspace daily data ingestion quota in GB (only used if enable_monitoring = true)"
  type        = number
  default     = 1
}