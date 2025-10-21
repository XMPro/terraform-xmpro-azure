output "app_name" {
  description = "The name of the AI app service"
  value       = azurerm_linux_web_app.ai_app.name
}

output "app_url" {
  description = "The URL of the AI app service"
  value       = "https://${azurerm_linux_web_app.ai_app.default_hostname}"
}

output "app_id" {
  description = "The ID of the AI app service"
  value       = azurerm_linux_web_app.ai_app.id
}

output "key_vault_id" {
  description = "The ID of the AI key vault"
  value       = data.azurerm_key_vault.ai_key_vault.id
}

output "key_vault_name" {
  description = "The name of the AI key vault"
  value       = data.azurerm_key_vault.ai_key_vault.name
}

output "service_plan_id" {
  description = "The ID of the AI service plan"
  value       = data.azurerm_service_plan.ai_service_plan.id
}

output "service_plan_name" {
  description = "The name of the AI service plan"
  value       = data.azurerm_service_plan.ai_service_plan.name
}

output "key_vault_secret_ids" {
  description = "Map of secret names to their IDs in the AI key vault"
  value       = module.ai_secrets.secret_ids
}

output "app_service_default_hostname" {
  description = "The default hostname of the AI app service"
  value       = azurerm_linux_web_app.ai_app.default_hostname
}

output "app_service_custom_domain_verification_id" {
  description = "The custom domain verification ID for the AI app service"
  value       = azurerm_linux_web_app.ai_app.custom_domain_verification_id
}