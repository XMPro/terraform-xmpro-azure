output "redis_id" {
  description = "The ID of the Redis cache"
  value       = azurerm_redis_cache.redis.id
}

output "redis_hostname" {
  description = "The hostname of the Redis cache"
  value       = azurerm_redis_cache.redis.hostname
}

output "redis_port" {
  description = "The SSL port of the Redis cache"
  value       = azurerm_redis_cache.redis.ssl_port
}

output "redis_primary_access_key" {
  description = "The primary access key for the Redis cache"
  value       = azurerm_redis_cache.redis.primary_access_key
  sensitive   = true
}

output "redis_secondary_access_key" {
  description = "The secondary access key for the Redis cache"
  value       = azurerm_redis_cache.redis.secondary_access_key
  sensitive   = true
}

output "redis_primary_connection_string" {
  description = "The primary connection string for the Redis cache"
  value       = azurerm_redis_cache.redis.primary_connection_string
  sensitive   = true
}

output "redis_secondary_connection_string" {
  description = "The secondary connection string for the Redis cache"
  value       = azurerm_redis_cache.redis.secondary_connection_string
  sensitive   = true
}

output "redis_configuration" {
  description = "The Redis configuration"
  value = {
    hostname            = azurerm_redis_cache.redis.hostname
    port                = azurerm_redis_cache.redis.ssl_port
    ssl_enabled         = true
    non_ssl_port        = azurerm_redis_cache.redis.port
    sku_name            = azurerm_redis_cache.redis.sku_name
    family              = azurerm_redis_cache.redis.family
    capacity            = azurerm_redis_cache.redis.capacity
  }
}