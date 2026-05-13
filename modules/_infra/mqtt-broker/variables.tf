# MQTT Broker Module Variables

variable "company_name" {
  description = "Company name used in resource naming"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "log_analytics_workspace_resource_id" {
  description = "Full ARM resource ID of Log Analytics workspace (required for Container App Environment)"
  type        = string
}

variable "mqtt_user" {
  description = "MQTT broker username. Leave empty to auto-generate."
  type        = string
  default     = ""
}

variable "mqtt_password" {
  description = "MQTT broker password. Leave empty to auto-generate."
  type        = string
  sensitive   = true
  default     = ""
}

variable "mqtt_cpu" {
  description = "CPU cores for MQTT broker container (e.g., 0.25, 0.5, 1.0)"
  type        = number
  default     = 0.25
}

variable "mqtt_memory" {
  description = "Memory for MQTT broker container (e.g., '0.5Gi', '1.0Gi')"
  type        = string
  default     = "0.5Gi"
}

variable "infrastructure_subnet_id" {
  description = "Subnet ID for the Container App Environment. Required for external TCP ingress."
  type        = string
  default     = null
}

variable "enable_tls" {
  description = "Enable TLS encryption for the MQTT broker using a self-signed certificate from Key Vault. When enabled, the broker listens on port 8883 instead of 1883."
  type        = bool
  default     = true
}

variable "key_vault_id" {
  description = "Key Vault ID for storing the TLS certificate. Required when enable_tls is true."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
