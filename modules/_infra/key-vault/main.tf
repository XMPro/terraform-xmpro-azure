# Azure Key Vault for storing sensitive configuration
resource "azurerm_key_vault" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
  enable_rbac_authorization  = var.enable_rbac_authorization
  tags                       = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# RBAC role assignment for Terraform to manage Key Vault
# This replaces the access policy approach
# Only created when RBAC authorization is enabled
resource "azurerm_role_assignment" "terraform_admin" {
  count                = var.enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.this.id
  role_definition_name = var.keyvault_admin_role_name
  principal_id         = var.object_id

  lifecycle {
    create_before_destroy = true
  }
}

# Access policy for Terraform principal to manage Key Vault
# Only created when RBAC authorization is disabled
resource "azurerm_key_vault_access_policy" "terraform_admin" {
  count        = var.enable_rbac_authorization ? 0 : 1
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
  ]
}

# Access policies from the provided map
# Only created when RBAC authorization is disabled
resource "azurerm_key_vault_access_policy" "policies" {
  for_each = var.enable_rbac_authorization ? {} : var.access_policies

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = each.value.object_id

  certificate_permissions = each.value.certificate_permissions
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
}

# Create secrets from the provided map
resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_key_vault.this,
    azurerm_role_assignment.terraform_admin,
    azurerm_key_vault_access_policy.terraform_admin
  ]
}
