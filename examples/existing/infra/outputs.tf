# Existing Database Example - Infrastructure Outputs
# These outputs are consumed by the application layer

output "resource_group_name" {
  description = "Resource group name"
  value       = module.infrastructure.resource_group_name
}

output "resource_group_location" {
  description = "Resource group location"
  value       = module.infrastructure.resource_group_location
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN (existing)"
  value       = module.infrastructure.sql_server_fqdn
  sensitive   = true
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.infrastructure.storage_account_name
}

output "storage_sas_token" {
  description = "Storage SAS token"
  value       = module.infrastructure.storage_sas_token
  sensitive   = true
}

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

output "ad_service_plan_name" {
  description = "AD App Service Plan name"
  value       = module.infrastructure.ad_service_plan_name
}

output "ds_service_plan_name" {
  description = "DS App Service Plan name"
  value       = module.infrastructure.ds_service_plan_name
}

output "sm_service_plan_name" {
  description = "SM App Service Plan name"
  value       = module.infrastructure.sm_service_plan_name
}

output "ai_service_plan_name" {
  description = "AI App Service Plan name"
  value       = module.infrastructure.ai_service_plan_name
}

output "app_insights_name" {
  description = "Application Insights name"
  value       = module.infrastructure.app_insights_name
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = module.infrastructure.log_analytics_workspace_name
}

output "name_suffix" {
  description = "Name suffix for app layer"
  value       = module.infrastructure.name_suffix
}
