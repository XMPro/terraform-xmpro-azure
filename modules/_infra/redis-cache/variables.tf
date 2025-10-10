variable "company_name" {
  description = "Company name for resource naming"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource naming to ensure uniqueness (required)"
  type        = string
  validation {
    condition     = length(var.name_suffix) > 0
    error_message = "name_suffix must not be empty to ensure unique Redis cache names."
  }
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "redis_capacity" {
  description = "The size of the Redis cache to deploy"
  type        = number
  default     = 0
}

variable "redis_family" {
  description = "The SKU family/pricing group to use"
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "The SKU of Redis to use"
  type        = string
  default     = "Standard"
}

variable "redis_maxmemory_reserved" {
  description = "The value in megabytes reserved for non-cache operations"
  type        = number
  default     = 50
}

variable "redis_maxmemory_delta" {
  description = "The max-memory delta for the Redis instance"
  type        = number
  default     = 50
}

variable "redis_maxmemory_policy" {
  description = "How Redis will select what to remove when maxmemory is reached"
  type        = string
  default     = "allkeys-lru"
}

variable "redis_maxfragmentationmemory_reserved" {
  description = "The value in megabytes reserved to accommodate memory fragmentation"
  type        = number
  default     = 50
}

variable "redis_enable_backup" {
  description = "Enable Redis backup"
  type        = bool
  default     = false
}

variable "redis_backup_frequency" {
  description = "The backup frequency in minutes"
  type        = number
  default     = 60
}

variable "redis_backup_max_snapshot_count" {
  description = "The maximum number of snapshots to create as a backup"
  type        = number
  default     = 1
}

variable "redis_backup_storage_connection_string" {
  description = "The connection string to the storage account for backup"
  type        = string
  default     = ""
  sensitive   = true
}

variable "redis_public_network_access_enabled" {
  description = "Whether public network access is enabled"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}