# Infrastructure Layer Outputs
# These outputs are consumed by the application layer

# Resource Group outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = module.resource_group.location
}

# DNS outputs
output "dns_zone_name" {
  description = "The name of the DNS zone"
  value       = var.enable_custom_domain ? module.dns_zone[0].name : ""
}

output "dns_zone_nameservers" {
  description = "The nameservers of the DNS zone"
  value       = var.enable_custom_domain ? module.dns_zone[0].name_servers : []
}

# Storage Account outputs
output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = module.storage_account.primary_access_key
  sensitive   = true
}

output "storage_sas_token" {
  description = "SAS token for storage account"
  value       = module.storage_account.sas_token
  sensitive   = true
}

output "storage_file_shares" {
  description = "The file shares created in the storage account"
  value       = module.storage_account.file_shares
}

# Database outputs
output "sql_server_name" {
  description = "The name of the SQL server"
  value       = var.use_existing_database ? split(".", var.existing_sql_server_fqdn)[0] : try(module.database[0].sql_server_name, "")
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = var.use_existing_database ? var.existing_sql_server_fqdn : try(module.database[0].sql_server_fqdn, "")
}

output "database_ids" {
  description = "The IDs of the databases"
  value       = var.use_existing_database ? {} : try(module.database[0].database_ids, {})
}

# Master Data Database outputs
output "masterdata_sql_server_name" {
  description = "The name of the Master Data SQL server (if created)"
  value       = var.create_masterdata ? module.masterdata_database[0].sql_server_name : ""
}

output "masterdata_sql_server_fqdn" {
  description = "The FQDN of the Master Data SQL server (if created)"
  value       = var.create_masterdata ? module.masterdata_database[0].sql_server_fqdn : ""
}

# Redis Cache outputs
output "redis_hostname" {
  description = "The hostname of the Redis cache"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_hostname : null
}

output "redis_port" {
  description = "The SSL port of the Redis cache"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_port : null
}

output "redis_primary_connection_string" {
  description = "The primary connection string for the Redis cache"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_primary_connection_string : null
  sensitive   = true
}

output "redis_configuration" {
  description = "The Redis cache configuration"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_configuration : null
}

# Monitoring outputs
output "app_insights_name" {
  description = "The name of the Application Insights instance"
  value       = module.monitoring.app_insights_name
}

output "app_insights_id" {
  description = "The ID of the Application Insights instance"
  value       = module.monitoring.app_insights_id
}

output "app_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = module.monitoring.app_insights_instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "The connection string for Application Insights"
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_primary_shared_key" {
  description = "The primary shared key for the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_primary_shared_key
  sensitive   = true
}

# Key Vault outputs
output "ad_key_vault_name" {
  description = "AD Key Vault name"
  value       = module.key_vault_ad.name
}

output "ad_key_vault_id" {
  description = "AD Key Vault resource ID"
  value       = module.key_vault_ad.id
}

output "ds_key_vault_name" {
  description = "DS Key Vault name"
  value       = module.key_vault_ds.name
}

output "ds_key_vault_id" {
  description = "DS Key Vault resource ID"
  value       = module.key_vault_ds.id
}

output "sm_key_vault_name" {
  description = "SM Key Vault name"
  value       = module.key_vault_sm.name
}

output "sm_key_vault_id" {
  description = "SM Key Vault resource ID"
  value       = module.key_vault_sm.id
}

output "ai_key_vault_name" {
  description = "The name of the AI key vault"
  value       = var.enable_ai ? module.key_vault_ai[0].name : ""
}

output "ai_key_vault_id" {
  description = "The ID of the AI key vault"
  value       = var.enable_ai ? module.key_vault_ai[0].id : ""
}

# App Service Plan outputs
output "ad_service_plan_name" {
  description = "AD App Service Plan name"
  value       = module.app_service_plan_ad.name
}

output "ad_service_plan_id" {
  description = "AD App Service Plan ID"
  value       = module.app_service_plan_ad.id
}

output "ds_service_plan_name" {
  description = "DS App Service Plan name"
  value       = module.app_service_plan_ds.name
}

output "ds_service_plan_id" {
  description = "DS App Service Plan ID"
  value       = module.app_service_plan_ds.id
}

output "sm_service_plan_name" {
  description = "SM App Service Plan name"
  value       = module.app_service_plan_sm.name
}

output "sm_service_plan_id" {
  description = "SM App Service Plan ID"
  value       = module.app_service_plan_sm.id
}

output "ai_service_plan_name" {
  description = "AI App Service Plan name (null if AI disabled)"
  value       = var.enable_ai ? module.app_service_plan_ai[0].name : null
}

output "ai_service_plan_id" {
  description = "AI App Service Plan ID (null if AI disabled)"
  value       = var.enable_ai ? module.app_service_plan_ai[0].id : null
}

# Networking outputs are defined in _networking.tf

# Common outputs for app layer
output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}

output "name_suffix" {
  description = "Name suffix for resource consistency"
  value       = var.name_suffix
}

# App Database Managed Identities - Used for app service assignment and AAD authentication
output "sm_db_managed_identity_name" {
  description = "Name of the SM database managed identity for resource assignment (null if AAD auth disabled or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth ? module.aad_identities[0].sm_app_identity_name : null)
}

output "sm_db_aad_client_id" {
  description = "Client ID of the SM database managed identity for AAD authentication (null if AAD auth disabled or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth ? module.aad_identities[0].sm_app_client_id : null)
}

output "ad_db_managed_identity_name" {
  description = "Name of the AD database managed identity for resource assignment (null if AAD auth disabled or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth ? module.aad_identities[0].ad_app_identity_name : null)
}

output "ad_db_aad_client_id" {
  description = "Client ID of the AD database managed identity for AAD authentication (null if AAD auth disabled or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth ? module.aad_identities[0].ad_app_client_id : null)
}

output "ds_db_managed_identity_name" {
  description = "Name of the DS database managed identity for resource assignment (null if AAD auth disabled or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth ? module.aad_identities[0].ds_app_identity_name : null)
}

output "ds_db_aad_client_id" {
  description = "Client ID of the DS database managed identity for AAD authentication (null if AAD auth disabled or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth ? module.aad_identities[0].ds_app_client_id : null)
}

output "ai_db_managed_identity_name" {
  description = "Name of the AI database managed identity for resource assignment (null if AAD auth disabled, AI disabled, or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth && var.enable_ai ? module.aad_identities[0].ai_app_identity_name : null)
}

output "ai_db_aad_client_id" {
  description = "Client ID of the AI database managed identity for AAD authentication (null if AAD auth disabled, AI disabled, or using existing database)"
  value       = var.use_existing_database ? null : (var.enable_sql_aad_auth && var.enable_ai ? module.aad_identities[0].ai_app_client_id : null)
}