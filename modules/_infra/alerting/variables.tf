variable "company_name" {
  description = "Company name for resource naming and identification"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource naming to ensure uniqueness (required)"
  type        = string
  validation {
    condition     = length(var.name_suffix) > 0
    error_message = "name_suffix must not be empty to ensure unique alert resource names."
  }
}

variable "location" {
  description = "The Azure location where all resources in this module should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the alerting resources"
  type        = string
}

variable "app_insights_id" {
  description = "The ID of the Application Insights instance to use for availability tests"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# Alerting variables
variable "enable_alerting" {
  description = "Master switch to enable or disable all alerting resources"
  type        = bool
  default     = false
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

# Alert configuration variables
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

# Container-specific variables
variable "container_group_id" {
  description = "The ID of the container group to monitor (optional, for container alerts)"
  type        = string
  default     = null
}

variable "enable_cpu_alerts" {
  description = "Enable CPU usage alerts for containers"
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

variable "stream_host_cpu_cores" {
  description = "Number of CPU cores allocated to the stream host (for threshold calculation)"
  type        = number
  default     = 2
}

variable "enable_memory_alerts" {
  description = "Enable memory usage alerts for containers"
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

variable "stream_host_memory_gb" {
  description = "Amount of memory in GB allocated to the stream host (for threshold calculation)"
  type        = number
  default     = 4
}

variable "enable_container_restart_alerts" {
  description = "Enable container restart alerts"
  type        = bool
  default     = false
}

variable "enable_container_stop_alerts" {
  description = "Enable container stop alerts"
  type        = bool
  default     = false
}