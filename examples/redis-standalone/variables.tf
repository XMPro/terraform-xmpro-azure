variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "xmpro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "shared"
  
  validation {
    condition     = can(regex("^(dev|qa|staging|prod|shared|sandbox).*$", var.environment))
    error_message = "Environment must be one of: dev*, qa*, staging, prod, shared, sandbox"
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "southeastasia"
}

variable "redis_capacity" {
  description = "Redis cache capacity"
  type        = number
  default     = 0
}

variable "redis_family" {
  description = "Redis SKU family"
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "Redis SKU name"
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Purpose     = "SharedRedisCache"
    ManagedBy   = "Terraform"
    Environment = "Shared"
  }
}