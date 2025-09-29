# Azure Key Vault Module

This module creates an Azure Key Vault for storing sensitive configuration values such as secrets, certificates, and keys.

## Usage

```hcl
data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "../modules/key-vault"
  
  name                = "kv-${var.prefix}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  
  secrets = {
    "db-admin-username" = {
      value = var.db_admin_username
    },
    "db-admin-password" = {
      value = var.db_admin_password
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Key Vault | `string` | n/a | yes |
| location | The Azure location where the Key Vault should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Key Vault | `string` | n/a | yes |
| tenant_id | The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault | `string` | n/a | yes |
| object_id | The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault | `string` | n/a | yes |
| sku_name | The Name of the SKU used for this Key Vault. Possible values are standard and premium | `string` | `"standard"` | no |
| purge_protection_enabled | Is Purge Protection enabled for this Key Vault? | `bool` | `false` | no |
| soft_delete_retention_days | The number of days that items should be retained for once soft-deleted | `number` | `7` | no |
| secrets | A map of secrets to store in the Key Vault | `map(object({ value = string }))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Key Vault |
| name | The name of the Key Vault |
| vault_uri | The URI of the Key Vault |
| secret_ids | Map of secret names to their IDs |
| secret_values | Map of secret names to their values (sensitive) |
