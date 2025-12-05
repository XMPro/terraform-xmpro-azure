output "aad_sql_users_identity_id" {
  description = "ID of the AAD SQL users managed identity"
  value       = azurerm_user_assigned_identity.aad_sql_users.id
}

output "aad_sql_users_identity_name" {
  description = "Name of the AAD SQL users managed identity"
  value       = azurerm_user_assigned_identity.aad_sql_users.name
}

output "aad_sql_users_principal_id" {
  description = "Principal ID of the AAD SQL users managed identity"
  value       = azurerm_user_assigned_identity.aad_sql_users.principal_id
}

output "aad_sql_users_client_id" {
  description = "Client ID of the AAD SQL users managed identity"
  value       = azurerm_user_assigned_identity.aad_sql_users.client_id
}

output "sm_app_identity_name" {
  description = "Name of the SM app managed identity"
  value       = azurerm_user_assigned_identity.sm_app.name
}

output "sm_app_client_id" {
  description = "Client ID of the SM app managed identity"
  value       = azurerm_user_assigned_identity.sm_app.client_id
}

output "ad_app_identity_name" {
  description = "Name of the AD app managed identity"
  value       = azurerm_user_assigned_identity.ad_app.name
}

output "ad_app_client_id" {
  description = "Client ID of the AD app managed identity"
  value       = azurerm_user_assigned_identity.ad_app.client_id
}

output "ds_app_identity_name" {
  description = "Name of the DS app managed identity"
  value       = azurerm_user_assigned_identity.ds_app.name
}

output "ds_app_client_id" {
  description = "Client ID of the DS app managed identity"
  value       = azurerm_user_assigned_identity.ds_app.client_id
}

output "ai_app_identity_name" {
  description = "Name of the AI app managed identity (null if AI disabled)"
  value       = var.enable_ai ? azurerm_user_assigned_identity.ai_app[0].name : null
}

output "ai_app_client_id" {
  description = "Client ID of the AI app managed identity (null if AI disabled)"
  value       = var.enable_ai ? azurerm_user_assigned_identity.ai_app[0].client_id : null
}
