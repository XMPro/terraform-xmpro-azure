# Infrastructure Layer Outputs

output "name_suffix" {
  description = "Random suffix for resource naming - REQUIRED for application layer"
  value       = module.infrastructure.name_suffix
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.infrastructure.resource_group_name
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.infrastructure.sql_server_fqdn
  sensitive   = true
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.infrastructure.storage_account_name
}

output "storage_account_sas_token" {
  description = "Storage account SAS token"
  value       = module.infrastructure.storage_sas_token
  sensitive   = true
}

output "ad_service_plan_name" {
  description = "AD App Service Plan Name"
  value       = module.infrastructure.ad_service_plan_name
}

output "ds_service_plan_name" {
  description = "DS App Service Plan Name"
  value       = module.infrastructure.ds_service_plan_name
}

output "sm_service_plan_name" {
  description = "SM App Service Plan Name"
  value       = module.infrastructure.sm_service_plan_name
}

output "ai_service_plan_name" {
  description = "AI App Service Plan Name (null if AI disabled)"
  value       = module.infrastructure.ai_service_plan_name
}


# Key Vault outputs
output "ad_key_vault_name" {
  description = "AD Key Vault name"
  value       = module.infrastructure.ad_key_vault_name
}

output "ds_key_vault_name" {
  description = "DS Key Vault name"
  value       = module.infrastructure.ds_key_vault_name
}

output "sm_key_vault_name" {
  description = "SM Key Vault name"
  value       = module.infrastructure.sm_key_vault_name
}

output "ai_key_vault_name" {
  description = "AI Key Vault name"
  value       = module.infrastructure.ai_key_vault_name
}

# Monitoring outputs
output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name (null if monitoring disabled)"
  value       = module.infrastructure.log_analytics_workspace_name
}

output "app_insights_name" {
  description = "Application Insights name (null if monitoring disabled)"
  value       = module.infrastructure.app_insights_name
}

# Redis Cache outputs
output "redis_primary_connection_string" {
  description = "Redis primary connection string (null if Redis not created)"
  value       = module.infrastructure.redis_primary_connection_string
  sensitive   = true
}

# Networking outputs
output "vnet_id" {
  description = "Virtual Network ID (null if networking disabled)"
  value       = module.infrastructure.vnet_id
}

output "vnet_name" {
  description = "Virtual Network name (null if networking disabled)"
  value       = module.infrastructure.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.infrastructure.subnet_ids
}

output "subnet_names" {
  description = "Map of subnet tier to subnet names"
  value       = module.infrastructure.subnet_names
}

output "private_dns_zone_ids" {
  description = "Map of DNS zone types to their IDs"
  value       = module.infrastructure.private_dns_zone_ids
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = module.infrastructure.nsg_ids
}

# App Database Managed Identities - Used for app service assignment and AAD authentication
output "sm_db_managed_identity_name" {
  description = "Name of the SM database managed identity for resource assignment (null if AAD auth disabled or using existing database)"
  value       = module.infrastructure.sm_db_managed_identity_name
}

output "sm_db_aad_client_id" {
  description = "Client ID of the SM database managed identity for AAD authentication (null if AAD auth disabled or using existing database)"
  value       = module.infrastructure.sm_db_aad_client_id
}

output "ad_db_managed_identity_name" {
  description = "Name of the AD database managed identity for resource assignment (null if AAD auth disabled or using existing database)"
  value       = module.infrastructure.ad_db_managed_identity_name
}

output "ad_db_aad_client_id" {
  description = "Client ID of the AD database managed identity for AAD authentication (null if AAD auth disabled or using existing database)"
  value       = module.infrastructure.ad_db_aad_client_id
}

output "ds_db_managed_identity_name" {
  description = "Name of the DS database managed identity for resource assignment (null if AAD auth disabled or using existing database)"
  value       = module.infrastructure.ds_db_managed_identity_name
}

output "ds_db_aad_client_id" {
  description = "Client ID of the DS database managed identity for AAD authentication (null if AAD auth disabled or using existing database)"
  value       = module.infrastructure.ds_db_aad_client_id
}

output "ai_db_managed_identity_name" {
  description = "Name of the AI database managed identity for resource assignment (null if AAD auth disabled, AI disabled, or using existing database)"
  value       = module.infrastructure.ai_db_managed_identity_name
}

output "ai_db_aad_client_id" {
  description = "Client ID of the AI database managed identity for AAD authentication (null if AAD auth disabled, AI disabled, or using existing database)"
  value       = module.infrastructure.ai_db_aad_client_id
}