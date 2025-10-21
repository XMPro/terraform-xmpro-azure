# This module manages secrets in an existing Key Vault
# The Key Vault must already exist (created in infrastructure layer)

# Reference the existing Key Vault
data "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

# Create/update secrets in the Key Vault
resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = data.azurerm_key_vault.this.id

  tags = var.tags
}