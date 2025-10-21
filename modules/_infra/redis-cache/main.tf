resource "azurerm_redis_cache" "redis" {
  name                 = "redis-${var.company_name}-${var.name_suffix}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  capacity             = var.redis_capacity
  family               = var.redis_family
  sku_name             = var.redis_sku_name
  non_ssl_port_enabled = false
  minimum_tls_version  = "1.2"

  redis_configuration {
    maxmemory_reserved              = var.redis_maxmemory_reserved
    maxmemory_delta                 = var.redis_maxmemory_delta
    maxmemory_policy                = var.redis_maxmemory_policy
    maxfragmentationmemory_reserved = var.redis_maxfragmentationmemory_reserved
    rdb_backup_enabled              = var.redis_enable_backup
    rdb_backup_frequency            = var.redis_enable_backup ? var.redis_backup_frequency : null
    rdb_backup_max_snapshot_count   = var.redis_enable_backup ? var.redis_backup_max_snapshot_count : null
    rdb_storage_connection_string   = var.redis_enable_backup ? var.redis_backup_storage_connection_string : null
  }

  public_network_access_enabled = var.redis_public_network_access_enabled

  tags = merge(
    var.tags,
    {
      Company   = var.company_name
      Component = "Redis"
    }
  )
}

# Create firewall rules for public access if enabled
resource "azurerm_redis_firewall_rule" "allow_azure_services" {
  count               = var.redis_public_network_access_enabled ? 1 : 0
  name                = "AllowAzureServices"
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = var.resource_group_name
  start_ip            = "0.0.0.0"
  end_ip              = "0.0.0.0"
}