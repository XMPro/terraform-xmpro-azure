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

# Redis Cache outputs
output "redis_primary_connection_string" {
  description = "Redis primary connection string (null if Redis not created)"
  value       = module.infrastructure.redis_primary_connection_string
  sensitive   = true
}