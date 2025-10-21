output "id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "secret_ids" {
  description = "Map of secret names to their versionless IDs for Key Vault references"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.versionless_id }
}

output "secret_values" {
  description = "Map of secret names to their values (sensitive)"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.value }
  sensitive   = true
}
