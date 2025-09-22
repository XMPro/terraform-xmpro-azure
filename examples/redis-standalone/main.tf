terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate unique suffix for resource naming
resource "random_id" "unique" {
  byte_length = 4
}

# Create resource group
resource "azurerm_resource_group" "redis" {
  name     = "${var.prefix}-redis-${var.environment}-${random_id.unique.hex}"
  location = var.location
  tags     = var.tags
}

# Create Redis Cache
module "redis_cache" {
  source = "../../modules/redis-cache"
  
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.redis.name
  unique_suffix       = random_id.unique.hex
  
  redis_capacity  = var.redis_capacity
  redis_family    = var.redis_family
  redis_sku_name  = var.redis_sku_name
  
  tags = var.tags
}

# Output the connection string for use in main deployment
output "redis_connection_string" {
  value       = module.redis_cache.redis_primary_connection_string
  sensitive   = true
  description = "Redis primary connection string to use in main deployment"
}

output "redis_hostname" {
  value       = module.redis_cache.redis_hostname
  description = "Redis hostname"
}

output "redis_resource_group" {
  value       = azurerm_resource_group.redis.name
  description = "Resource group containing Redis cache"
}

output "instructions" {
  value = <<-EOT
    
    Redis Cache deployed successfully!
    
    To use this Redis cache in your main XMPro deployment:
    
    1. Export the connection string:
       export TF_VAR_redis_connection_string=$(terraform output -raw redis_connection_string)
    
    2. In your main deployment, set:
       enable_auto_scale = true
       create_redis_cache = false
       redis_connection_string = var.redis_connection_string
    
    3. Or add to terraform.tfvars:
       redis_connection_string = "<connection_string_value>"
  EOT
}