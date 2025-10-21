# Azure Key Vault for storing sensitive configuration
resource "azurerm_key_vault" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
  enable_rbac_authorization  = true # Use Azure RBAC instead of access policies
  tags                       = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# RBAC role assignment for Terraform to manage Key Vault
# This replaces the access policy approach
resource "azurerm_role_assignment" "terraform_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = var.keyvault_admin_role_name
  principal_id         = var.object_id

  lifecycle {
    create_before_destroy = true
  }
}

# Create secrets from the provided map
resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.terraform_admin]
}
