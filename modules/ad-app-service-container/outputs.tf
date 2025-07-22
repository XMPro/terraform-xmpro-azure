output "app_name" {
  description = "The name of the AD app service"
  value       = azurerm_linux_web_app.ad_app.name
}

output "app_url" {
  description = "The URL of the AD app service"
  value       = "https://${azurerm_linux_web_app.ad_app.default_hostname}"
}

output "app_id" {
  description = "The ID of the AD app service"
  value       = azurerm_linux_web_app.ad_app.id
}

output "key_vault_id" {
  description = "The ID of the AD key vault"
  value       = module.ad_key_vault.id
}

output "key_vault_name" {
  description = "The name of the AD key vault"
  value       = module.ad_key_vault.name
}

output "service_plan_id" {
  description = "The ID of the AD service plan"
  value       = azurerm_service_plan.ad_service_plan.id
}

output "service_plan_name" {
  description = "The name of the AD service plan"
  value       = azurerm_service_plan.ad_service_plan.name
}

output "key_vault_secret_ids" {
  description = "Map of secret names to their IDs in the AD key vault"
  value       = module.ad_key_vault.secret_ids
}

output "app_service_default_hostname" {
  description = "The default hostname of the AD app service"
  value       = azurerm_linux_web_app.ad_app.default_hostname
}

output "app_service_custom_domain_verification_id" {
  description = "The custom domain verification ID for the AD app service"
  value       = azurerm_linux_web_app.ad_app.custom_domain_verification_id
}