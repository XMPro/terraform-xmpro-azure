output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = data.azurerm_key_vault.this.id
}

output "secret_ids" {
  description = "The IDs of the created secrets"
  value = {
    for k, v in azurerm_key_vault_secret.secrets : k => v.id
  }
}

output "secret_versionless_ids" {
  description = "The versionless IDs of the created secrets (for Key Vault references)"
  value = {
    for k, v in azurerm_key_vault_secret.secrets : k => v.versionless_id
  }
}