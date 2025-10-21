output "app_name" {
  description = "The name of the SM app service"
  value       = azurerm_windows_web_app.sm_website.name
}

output "app_url" {
  description = "The URL of the SM app service"
  value       = "https://${azurerm_windows_web_app.sm_website.default_hostname}"
}

output "app_id" {
  description = "The ID of the SM app service"
  value       = azurerm_windows_web_app.sm_website.id
}

# Key Vault outputs removed - Key Vault is now managed at the top level

output "service_plan_id" {
  description = "The ID of the SM service plan"
  value       = data.azurerm_service_plan.sm_service_plan.id
}

output "service_plan_name" {
  description = "The name of the SM service plan"
  value       = data.azurerm_service_plan.sm_service_plan.name
}

output "zip_package_url" {
  description = "The URL of the SM zip package used for deployment"
  value       = "https://${var.storage_account_name}.file.core.windows.net/${var.files_location}/SM.zip${var.storage_sas_token}"
}

output "app_service_default_hostname" {
  description = "The default hostname of the SM app service"
  value       = azurerm_windows_web_app.sm_website.default_hostname
}

output "app_service_custom_domain_verification_id" {
  description = "The custom domain verification ID for the SM app service"
  value       = azurerm_windows_web_app.sm_website.custom_domain_verification_id
}

# Storage-related outputs
output "storage_account_name" {
  description = "The name of the storage account used for SM zip packages"
  value       = var.storage_account_name
}

output "storage_artifacts_share_url" {
  description = "The URL of the storage share containing SM artifacts"
  value       = "https://${var.storage_account_name}.file.core.windows.net/sm-artifacts"
}

output "zip_prep_container_name" {
  description = "The name of the container used for SM zip preparation"
  value       = "sm-zip-prep"
}

