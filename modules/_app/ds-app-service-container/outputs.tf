output "app_name" {
  description = "The name of the DS app service"
  value       = azurerm_linux_web_app.ds_app.name
}

output "app_url" {
  description = "The URL of the DS app service"
  value       = "https://${azurerm_linux_web_app.ds_app.default_hostname}"
}

output "app_id" {
  description = "The ID of the DS app service"
  value       = azurerm_linux_web_app.ds_app.id
}

output "key_vault_id" {
  description = "The ID of the DS key vault"
  value       = data.azurerm_key_vault.ds_key_vault.id
}

output "key_vault_name" {
  description = "The name of the DS key vault"
  value       = data.azurerm_key_vault.ds_key_vault.name
}

output "service_plan_id" {
  description = "The ID of the DS service plan"
  value       = data.azurerm_service_plan.ds_service_plan.id
}

output "service_plan_name" {
  description = "The name of the DS service plan"
  value       = data.azurerm_service_plan.ds_service_plan.name
}

output "key_vault_secret_ids" {
  description = "Map of secret names to their IDs in the DS key vault"
  value       = module.ds_secrets.secret_ids
}

output "app_service_default_hostname" {
  description = "The default hostname of the DS app service"
  value       = azurerm_linux_web_app.ds_app.default_hostname
}

output "app_service_custom_domain_verification_id" {
  description = "The custom domain verification ID for the DS app service"
  value       = azurerm_linux_web_app.ds_app.custom_domain_verification_id
}
